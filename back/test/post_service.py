# app_posts.py
from __future__ import annotations

import os
from datetime import datetime
from typing import Optional, List, Literal

from fastapi import FastAPI, Depends, HTTPException, Header, Query, status
from sqlmodel import Session, create_engine, select, SQLModel
from sqlalchemy import func, desc
from authlib.jose import jwt

# IMPORTANT:
# - Do NOT paste your schema here.
# - Put it in e.g. models.py and import the classes below.
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

# ---------------------------
# Config
# ---------------------------

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "nope",
)

JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_ALG = os.getenv("JWT_ALG", "HS256")

engine = create_engine(DATABASE_URL, echo=False, pool_pre_ping=True)

app = FastAPI(title="Posts API")


# ---------------------------
# DB session dependency
# ---------------------------

def get_session():
    with Session(engine) as session:
        yield session


# ---------------------------
# Auth (Bearer token, no cookies/sessions)
# ---------------------------

def _unauthorized(detail: str = "Unauthorized"):
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)


def get_current_user(
    session: Session = Depends(get_session),
    authorization: Optional[str] = Header(default=None),
) -> User:
    if not authorization or not authorization.lower().startswith("bearer "):
        _unauthorized("Missing Bearer token")

    token = authorization.split(" ", 1)[1].strip()
    try:
        claims = jwt.decode(token, JWT_SECRET)
        claims.validate()  # validates exp/nbf if present
    except Exception:
        _unauthorized("Invalid token")

    user_id = claims.get("sub")
    if user_id is None:
        _unauthorized("Invalid token (missing sub)")

    user = session.get(User, int(user_id))
    if not user:
        _unauthorized("User not found")

    if user.status in (UserStatus.BANNED, UserStatus.DELETED):
        raise HTTPException(status_code=403, detail="Account disabled")

    return user


# ---------------------------
# Permission helpers
# ---------------------------

def get_community_or_404(session: Session, community_id: int) -> Community:
    community = session.get(Community, community_id)
    if not community or community.deleted_at is not None:
        raise HTTPException(status_code=404, detail="Community not found")
    return community


def get_post_or_404(session: Session, post_id: int) -> Post:
    post = session.get(Post, post_id)
    if not post or post.deleted_at is not None:
        raise HTTPException(status_code=404, detail="Post not found")
    return post


def require_can_post_in_community(session: Session, user: User, community: Community) -> None:
    # Public: anyone (authenticated) can post unless explicitly banned in community.
    # Restricted/Private: must be member/mod/owner (not banned).
    role_row = session.get(CommunityRoleAssignment, (community.id, user.id))

    if role_row and role_row.role == CommunityRole.BANNED:
        raise HTTPException(status_code=403, detail="Banned from community")

    if community.type == CommunityType.PUBLIC:
        return

    if not role_row or role_row.role not in (CommunityRole.MEMBER, CommunityRole.MOD, CommunityRole.OWNER):
        raise HTTPException(status_code=403, detail="Not allowed in this community")


def is_mod_or_owner(session: Session, user: User, community_id: int) -> bool:
    role_row = session.get(CommunityRoleAssignment, (community_id, user.id))
    return bool(role_row and role_row.role in (CommunityRole.MOD, CommunityRole.OWNER))


def require_author_or_mod(session: Session, user: User, post: Post) -> None:
    if post.author_user_id == user.id:
        return
    if is_mod_or_owner(session, user, post.community_id):
        return
    raise HTTPException(status_code=403, detail="Not allowed")


# ---------------------------
# API Schemas (request/response)
# ---------------------------

class PostCreate(SQLModel):
    title: str
    body: Optional[str] = None
    image_url: Optional[str] = None  # client "image?" -> stored as image_url


class PostUpdate(SQLModel):
    title: Optional[str] = None
    body: Optional[str] = None
    image_url: Optional[str] = None


class PostOut(SQLModel):
    id: int
    community_id: int
    author_user_id: int
    title: str
    body: Optional[str]
    image_url: Optional[str]
    created_at: datetime
    edited_at: Optional[datetime]
    score: int = 0  # computed


# ---------------------------
# Routes: createPost / getPost / listPosts / updatePost / deletePost
# ---------------------------

@app.post("/posts", response_model=PostOut)
def create_post(
    community_id: int,
    payload: PostCreate,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    community = get_community_or_404(session, community_id)
    require_can_post_in_community(session, me, community)

    post = Post(
        community_id=community_id,
        author_user_id=me.id,
        title=payload.title,
        body=payload.body,
        image_url=payload.image_url,
        created_at=datetime.utcnow(),
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
        edited_at=post.edited_at,
        score=0,
    )


@app.get("/posts/{post_id}", response_model=PostOut)
def get_post(
    post_id: int,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    post = get_post_or_404(session, post_id)

    # ensure community still exists (and handle private/restricted visibility)
    community = get_community_or_404(session, post.community_id)

    # visibility: public ok; otherwise must be member/mod/owner and not banned
    require_can_post_in_community(session, me, community)  # same logic works for view

    score = session.exec(
        select(func.coalesce(func.sum(PostVote.value), 0)).where(PostVote.post_id == post.id)
    ).one()

    return PostOut(
        id=post.id,
        community_id=post.community_id,
        author_user_id=post.author_user_id,
        title=post.title,
        body=post.body,
        image_url=post.image_url,
        created_at=post.created_at,
        edited_at=post.edited_at,
        score=int(score or 0),
    )


@app.get("/posts", response_model=List[PostOut])
def list_posts(
    community_id: Optional[int] = None,
    author_id: Optional[int] = None,
    sort: Literal["new", "top"] = "new",
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    offset = (page - 1) * page_size

    # Base query filters
    filters = [Post.deleted_at.is_(None)]
    if community_id is not None:
        # Also enforces community exists + visibility
        community = get_community_or_404(session, community_id)
        require_can_post_in_community(session, me, community)
        filters.append(Post.community_id == community_id)

    if author_id is not None:
        filters.append(Post.author_user_id == author_id)

    # "new": order by created_at desc
    if sort == "new":
        stmt = (
            select(Post)
            .where(*filters)
            .order_by(desc(Post.created_at))
            .offset(offset)
            .limit(page_size)
        )
        posts = session.exec(stmt).all()

        # scores in one go
        ids = [p.id for p in posts]
        scores_map = {}
        if ids:
            rows = session.exec(
                select(PostVote.post_id, func.coalesce(func.sum(PostVote.value), 0))
                .where(PostVote.post_id.in_(ids))
                .group_by(PostVote.post_id)
            ).all()
            scores_map = {int(pid): int(score or 0) for pid, score in rows}

        return [
            PostOut(
                id=p.id,
                community_id=p.community_id,
                author_user_id=p.author_user_id,
                title=p.title,
                body=p.body,
                image_url=p.image_url,
                created_at=p.created_at,
                edited_at=p.edited_at,
                score=scores_map.get(p.id, 0),
            )
            for p in posts
        ]

    # "top": order by sum(votes) desc, then created_at desc
    score_expr = func.coalesce(func.sum(PostVote.value), 0).label("score")
    stmt = (
        select(Post, score_expr)
        .outerjoin(PostVote, PostVote.post_id == Post.id)
        .where(*filters)
        .group_by(Post.id)
        .order_by(desc(score_expr), desc(Post.created_at))
        .offset(offset)
        .limit(page_size)
    )

    rows = session.exec(stmt).all()
    out: List[PostOut] = []
    for post, score in rows:
        out.append(
            PostOut(
                id=post.id,
                community_id=post.community_id,
                author_user_id=post.author_user_id,
                title=post.title,
                body=post.body,
                image_url=post.image_url,
                created_at=post.created_at,
                edited_at=post.edited_at,
                score=int(score or 0),
            )
        )
    return out


@app.patch("/posts/{post_id}", response_model=PostOut)
def update_post(
    post_id: int,
    payload: PostUpdate,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    post = get_post_or_404(session, post_id)
    get_community_or_404(session, post.community_id)  # ensures community not deleted
    require_author_or_mod(session, me, post)

    changed = False
    if payload.title is not None:
        post.title = payload.title
        changed = True
    if payload.body is not None:
        post.body = payload.body
        changed = True
    if payload.image_url is not None:
        post.image_url = payload.image_url
        changed = True

    if changed:
        post.edited_at = datetime.utcnow()

    session.add(post)
    session.commit()
    session.refresh(post)

    score = session.exec(
        select(func.coalesce(func.sum(PostVote.value), 0)).where(PostVote.post_id == post.id)
    ).one()

    return PostOut(
        id=post.id,
        community_id=post.community_id,
        author_user_id=post.author_user_id,
        title=post.title,
        body=post.body,
        image_url=post.image_url,
        created_at=post.created_at,
        edited_at=post.edited_at,
        score=int(score or 0),
    )


@app.delete("/posts/{post_id}", status_code=204)
def delete_post(
    post_id: int,
    session: Session = Depends(get_session),
    me: User = Depends(get_current_user),
):
    post = get_post_or_404(session, post_id)
    get_community_or_404(session, post.community_id)
    require_author_or_mod(session, me, post)

    post.deleted_at = datetime.utcnow()
    session.add(post)
    session.commit()
    return None


# ---------------------------
# Optional: dev runner
# ---------------------------

if __name__ == "__main__":
    # Create tables if you want (usually do this in a migration tool instead)
    # SQLModel.metadata.create_all(engine)

    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
