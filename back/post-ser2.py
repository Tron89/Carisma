# simple_api.py

from datetime import datetime, timedelta, timezone
from typing import Optional, List
import random

from fastapi import FastAPI, HTTPException, Depends, Header, status
from sqlmodel import SQLModel, Session, create_engine, select
from contextlib import asynccontextmanager
from dotenv import load_dotenv
load_dotenv()
import os
DATABASE_URL = os.getenv("DATABASE_URL")
from authlib.jose import jwt
JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALG = os.getenv("JWT_ALG")

from models import (
    User,
    UserStatus,
    Community,
    CommunityType,
    CommunityRole,
    CommunityRoleAssignment,
    Post,
    PostVote,
)

from schemas import *

# ---- App + DB ----

engine = create_engine(
    DATABASE_URL,
    echo=True, # set to True to see SQL logs
    pool_pre_ping=True,
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    SQLModel.metadata.create_all(engine)
    yield
    # shutdown

app = FastAPI(lifespan=lifespan)

# ---- Helper functions ----

# ---------- JWT ----------
def create_token(data: dict):
    exp = datetime.now(timezone.utc) + timedelta(hours=1)
    payload = {**data, "exp": exp}
    return jwt.encode({"alg": JWT_ALG}, payload, JWT_SECRET)


def verify_token(token: str):
    try:
        claims = jwt.decode(token, JWT_SECRET, claims_options={"exp": {"essential": True}})
        claims.validate()
        return claims
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_session():
    with Session(engine) as session:
        yield session

def _unauthorized(detail: str = "Unauthorized") -> None:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)

def get_current_user(
    session: Session = Depends(get_session),
    authorization: Optional[str] = Header(default=None),
) -> User:
    if not authorization or not authorization.lower().startswith("bearer "):
        _unauthorized("Missing Bearer token")

    token = authorization.split(" ", 1)[1].strip()
    claims = verify_token(token)

    sub = claims.get("sub")
    if sub is None:
        _unauthorized("Invalid token (missing sub)")

    user: Optional[User] = None


    if not user:
        _unauthorized("User not found")
    if user.status in (UserStatus.BANNED, UserStatus.DELETED):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account disabled")

    return user

def get_user(session: Session, userstr: str) -> Optional[User]:
    user: Optional[User] = None
    if isinstance(userstr, int) or (isinstance(userstr, str) and userstr.isdigit()):
        try:
            user_id = int(userstr)
        except (TypeError, ValueError):
            user_id = None
        if user_id is not None:
            user = session.get(User, user_id)

    if not user:
        user = session.exec(select(User).where(User.username == str(userstr))).first()
        
    return user

def get_or_create_user(session: Session, username: str) -> User:
    user = session.exec(select(User).where(User.username == username)).first()
    if user:
        return user
    user = User(username=username, email=username+"@example.com", password_hash=username+"hashed_dummy")
    session.add(user)
    session.commit()
    session.refresh(user)
    return user

def get_or_create_community(session: Session, name: str, owner_username: str) -> Community:
    c = session.exec(select(Community).where(Community.name == name)).first()
    if c:
        return c
    owner = get_or_create_user(session, owner_username)
    c = Community(name=name, title=name+" Community", owner_user_id=owner.id)
    session.add(c)
    session.commit()
    session.refresh(c)
    return c

# ---- Pydantic Schemas ----



# ---- 1) GET /posts -> 5 random posts ----

@app.get("/posts", response_model=List[PostOut])
def get_5_random_posts():
    with Session(engine) as session:
        posts = session.exec(select(Post)).all()
        if not posts:
            return []
        sample = random.sample(posts, k=min(5, len(posts)))

        # super simple response
        return [
            PostOut(
                id=p.id,
                community_id=p.community_id,
                author_user_id=p.author_user_id,
                title=p.title,
                body=p.body,
                image_url=p.image_url,
                created_at=p.created_at,
            )
            for p in sample
        ]

# ---- 2) POST /posts/new -> create post by usernames + community names ----

@app.post("/posts/new", response_model=PostCreateResponse)
def new_post(payload: PostCreatePayload):
    # expects: { "username": "...", "community": "...", "title": "...", "body": "...?", "image_url": "...?" }
    username = payload.username
    community_name = payload.community
    title = payload.title

    if not username or not community_name or not title:
        raise HTTPException(400, "username, community, title are required")

    with Session(engine) as session:
        user = get_or_create_user(session, username)
        community = get_or_create_community(session, community_name, username)

        post = Post(
            community_id=community.id,
            author_user_id=user.id,
            title=title,
            body=payload.body,
            image_url=payload.image_url,
            created_at=datetime.now(timezone.utc),
        )
        session.add(post)
        session.commit()
        session.refresh(post)

        return PostCreateResponse(id=post.id)

# ---- 3) POST /posts/{id}/thumb -> vote with dummy user ----

DUMMY_USERNAME = "default_dummy_user"

@app.post("/posts/{post_id}/thumb")
def thumb(post_id: int, payload: PostThumbPayload):
    # expects: { "value": 1 } or { "value": -1 }
    value = payload.value
    if value not in (1, -1):
        raise HTTPException(400, "value must be 1 or -1")

    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post:
            raise HTTPException(404, "post not found")

        dummy = get_or_create_user(session, DUMMY_USERNAME)

        # upsert-ish: update if exists else insert
        vote = session.get(PostVote, (post_id, dummy.id))
        if vote:
            vote.value = value
            vote.created_at = datetime.now(timezone.utc)
        else:
            vote = PostVote(post_id=post_id, user_id=dummy.id, value=value, created_at=datetime.now(timezone.utc))
            session.add(vote)

        session.commit()
        return {"ok": True, "post_id": post_id, "user": DUMMY_USERNAME, "value": value}

if __name__ == "__main__":
    # Create tables if you want (usually do this in a migration tool instead)
    # SQLModel.metadata.create_all(engine)

    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
