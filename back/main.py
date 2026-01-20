# main.py

# TODO: Validations of privileges needed

# ---------- IMPORTS ----------

from datetime import datetime, timedelta, timezone
from typing import Optional, List
import random
import secrets
import base64
import hashlib

from fastapi import FastAPI, HTTPException, Depends, Header, status, APIRouter
from sqlmodel import SQLModel, Session, create_engine, select
from contextlib import asynccontextmanager
from dotenv import load_dotenv
import os
from authlib.jose import jwt

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
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

# ---------- APP ----------

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
v1 = APIRouter(prefix="/v1")

# ---------- FUNCTIONS ----------

# ---- Basic Helpers ----

def get_session():
    with Session(engine) as session:
        yield session

def _unauthorized(detail: str = "Unauthorized") -> None:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)

# ---- JWT + Password ----
def create_token(data: dict):
    exp = datetime.now(timezone.utc) + timedelta(hours=24)
    payload = {**data, "exp": exp}
    return jwt.encode({"alg": JWT_ALG}, payload, JWT_SECRET)


def verify_token(token: str):
    try:
        claims = jwt.decode(token, JWT_SECRET, claims_options={"exp": {"essential": True}})
        claims.validate()
        return claims
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

def hash_password(plain_password: str) -> str:
    iterations = 210_000
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac(
        "sha256",
        plain_password.encode("utf-8"),
        salt,
        iterations,
    )
    return "pbkdf2_sha256${}${}${}".format(
        iterations,
        base64.b64encode(salt).decode("ascii"),
        base64.b64encode(digest).decode("ascii"),
    )

def verify_password(plain_password: str, password_hash: str) -> bool:
    parts = password_hash.split("$", 3)
    if len(parts) != 4 or parts[0] != "pbkdf2_sha256":
        return secrets.compare_digest(plain_password, password_hash)

    _, iter_str, salt_b64, digest_b64 = parts
    try:
        iterations = int(iter_str)
        salt = base64.b64decode(salt_b64)
        expected = base64.b64decode(digest_b64)
    except (ValueError, TypeError):
        return False

    test = hashlib.pbkdf2_hmac(
        "sha256",
        plain_password.encode("utf-8"),
        salt,
        iterations,
    )
    return secrets.compare_digest(test, expected)

# ---- Dependencies ----

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

    try:
        user_id = int(sub)
    except (TypeError, ValueError):
        _unauthorized("Invalid token (bad sub)")

    user = session.get(User, user_id)
    if not user:
        _unauthorized("User not found")
    if user.status in (UserStatus.BANNED, UserStatus.DELETED):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account disabled")

    return user

def get_optional_current_user(
    session: Session = Depends(get_session),
    authorization: Optional[str] = Header(default=None),
) -> Optional[User]:
    if not authorization:
        return None
    return get_current_user(session=session, authorization=authorization)

# ---- Getters ----
# (By id or name)

def get_user(
    userstr: str,
    session: Session = Depends(get_session),
    ) -> Optional[User]:
    user: Optional[User] = None
    if isinstance(userstr, int) or (isinstance(userstr, str) and userstr.isdigit()):
        user = session.get(User, int(userstr))

    if not user:
        user = session.exec(select(User).where(User.username == str(userstr))).first()
        
    return user

def get_community(
    communitystr: str,
    session: Session = Depends(get_session),
) -> Optional[Community]:
    community: Optional[Community] = None
    if isinstance(communitystr, int) or (isinstance(communitystr, str) and communitystr.isdigit()):
        community = session.get(Community, int(communitystr))

    if not community:
        community = session.exec(select(Community).where(Community.name == str(communitystr))).first()

    return community

# ---- API ENDPOINTS ----

# ---- Login ----

@v1.post("/register", response_model=UserPrivateOut, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreatePayload, session: Session = Depends(get_session)):
    if payload.username.isdigit():
        raise HTTPException(status_code=400, detail="username must include at least one letter")

    existing_user = session.exec(select(User).where(User.username == payload.username)).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="username already exists")

    existing_email = session.exec(select(User).where(User.email == payload.email)).first()
    if existing_email:
        raise HTTPException(status_code=409, detail="email already exists")

    user = User(
        username=payload.username,
        email=payload.email,
        password_hash=hash_password(payload.password),
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return UserPrivateOut(
        id=user.id,
        username=user.username,
        email=user.email,
        created_at=user.created_at,
        status=user.status,
        status_changed_at=user.status_changed_at,
        banned_reason=user.banned_reason,
    )

@v1.post("/login", response_model=LoginResponse)
def login(payload: LoginPayload, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.username == payload.username)).first()
    if not user or not verify_password(payload.password, user.password_hash):
        _unauthorized("Bad credentials")

    if user.status in (UserStatus.BANNED, UserStatus.DELETED):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account disabled")

    token = create_token({"sub": str(user.id)})
    return LoginResponse(
        access_token=token,
        token_type="bearer",
        user=UserPrivateOut(
            id=user.id,
            username=user.username,
            email=user.email,
            created_at=user.created_at,
            status=user.status,
            status_changed_at=user.status_changed_at,
            banned_reason=user.banned_reason,
        ),
    )

# ---- Communities ----

@v1.post("/communities", response_model=CommunityOut, status_code=status.HTTP_201_CREATED)
def new_community(
    payload: CommunityCreatePayload,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    existing = session.exec(select(Community).where(Community.name == payload.name)).first()
    if existing:
        raise HTTPException(status_code=409, detail="community already exists")

    community = Community(
        name=payload.name,
        description=payload.description,
        type=payload.type,
        owner_user_id=me.id,
    )
    session.add(community)
    session.commit()
    session.refresh(community)
    return CommunityOut(
        id=community.id,
        name=community.name,
        description=community.description,
        type=community.type,
        owner_user_id=community.owner_user_id,
        is_personal=community.is_personal, # TODO: maybe its not necesary the personal comunity
        personal_user_id=community.personal_user_id,
        created_at=community.created_at,
    )

@v1.get("/communities/{community_str}", response_model=CommunityOut)
def get_community_by_id(
    community_str: str,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    community = get_community(community_str, session=session)
    if not community or community.deleted_at is not None:
        raise HTTPException(status_code=404, detail="community not found")
    return CommunityOut(
        id=community.id,
        name=community.name,
        description=community.description,
        type=community.type,
        owner_user_id=community.owner_user_id,
        is_personal=community.is_personal,
        personal_user_id=community.personal_user_id,
        created_at=community.created_at,
    )


# ---- Posts ----

# 5 random posts
@v1.get("/posts", response_model=List[PostOut])
def get_5_random_posts(
    session: Session = Depends(get_session),
    me: Optional[User] = Depends(get_optional_current_user),
):
    _ = me
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

@v1.get("/posts/{post_id}", response_model=PostOut)
def get_post(
    post_id: int,
    session: Session = Depends(get_session),
    me: Optional[User] = Depends(get_optional_current_user),
):
    _ = me
    post = session.get(Post, post_id)
    if not post or post.deleted_at is not None:
        raise HTTPException(status_code=404, detail="post not found")

    return PostOut(
        id=post.id,
        community_id=post.community_id,
        author_user_id=post.author_user_id,
        title=post.title,
        body=post.body,
        image_url=post.image_url,
        created_at=post.created_at,
    )

@v1.post("/posts", response_model=PostOut, status_code=status.HTTP_201_CREATED)
def new_post(
    payload: PostCreatePayload,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    community = get_community(payload.community, session=session)
    if not community or community.deleted_at is not None:
        raise HTTPException(status_code=404, detail="community not found")

    post = Post(
        community_id=community.id,
        author_user_id=me.id,
        title=payload.title,
        body=payload.body,
        image_url=payload.image_url,
    )
    session.add(post)
    session.commit()
    session.refresh(post)
    return PostOut(
        id=post.id,
        community_id=post.community_id,
        author_user_id=post.author_user_id,
        title=post.title,
        body=post.body,
        image_url=post.image_url,
        created_at=post.created_at,
    )


app.include_router(v1)

if __name__ == "__main__":
    # Create tables if you want (usually do this in a migration tool instead)
    # SQLModel.metadata.create_all(engine)

    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
