# simple_api.py
# pip install fastapi uvicorn sqlmodel pymysql

from datetime import datetime
from typing import Optional, List

from fastapi import FastAPI, HTTPException, APIRouter, Query, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field as PydanticField
from sqlalchemy import func, or_
from sqlmodel import SQLModel, Session, create_engine, select

# ---- Minimal models (for quick testing) ----
from models import (
    User,
    UserStatus,
    Community,
    CommunityType,
    CommunityRole,
    CommunityRoleAssignment,
    Post,
    PostVote,
    Comment,
)

# ---- App + DB ----

app = FastAPI()

engine = create_engine(
    "",
    echo=False,
    pool_pre_ping=True,
)

@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)

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
  DUMMY_USERNAME = "default_dummy_user"

@app.exception_handler(HTTPException)
def http_exception_handler(request: Request, exc: HTTPException):
    detail = exc.detail
    if isinstance(detail, dict) and "error" in detail:
        content = detail
    else:
        content = {"error": {"code": "http_error", "message": str(detail)}}
    return JSONResponse(status_code=exc.status_code, content=content)

def raise_error(status_code: int, code: str, message: str, details: Optional[dict] = None) -> None:
    payload = {"error": {"code": code, "message": message}}
    if details:
        payload["error"]["details"] = details
    raise HTTPException(status_code=status_code, detail=payload)

class Meta(BaseModel):
    next_cursor: Optional[str] = None
    has_more: bool = False

class PostOut(BaseModel):
    id: int
    community_id: int
    author_id: int
    title: str
    body: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime
    score: int

class PostCreateIn(BaseModel):
    community_id: int
    title: str = PydanticField(min    community_id: Optional[int] = None
    community_name: Optional[str] = None
    title: str = PydanticField(min_length=1)
    body: Optional[str] = None
    image_url: Optional[str] = None
    author_id: Optional[int] = None
    author_username: Optional[str] = None
 = None
    body: Optional[str] = None
    image_url: Optional[str] = None

class PostCreateOut(BaseModel):
    id: int
    created_at: datetime

class PostListResponse(BaseModel):
    data: List[PostOut]
    meta: Meta

class PostResponse(BaseModel):
    data: PostOut

class PostCreateResponse(BaseModel):
    data: PostCreateOut

class DeleteOut(BaseModel):
    id: int

class DeleteResponse(BaseModel):
    data: DeleteOut

class VoteIn(BaseModel):
    value: int
    user_id: Optional[int] = None

class VoteOut(BaseModel):
    post_id: int
    user_id: int
    value: int

class VoteResponse(BaseModel):
    data: VoteOut

class CommentOut(BaseModel):
    id: int
    post_id: int
    author_id: int
    parent_comment_id: Optional[int] = None
    body: str
    created_at: datetime

class CommentListResponse(BaseModel):
    data: List[CommentOut]
    meta: Meta

class PostBatchIn(BaseModel):
    ids: List[int] = PydanticField(min_items=1, max_items=100)

class PostBatchResponse(BaseModel):
    data: List[PostOut]

def post_score_expr():
    return func.coalesce(func.sum(PostVote.value), 0).label("score")

def post_to_out(post: Post, score: int) -> PostOut:
    return PostOut(
        id=post.id,
        community_id=post.community_id,
        author_id=post.author_user_id,
        title=post.title,
        body=post.body,
        image_url=post.image_url,
        created_at=post.created_at,
        score=int(score or 0),
    )

def get_user_for_action(session: Session, user_id: Optional[int]) -> User:
    if user_id is not None:
        user = session.get(User, user_id)
        if not user:
            raise_error(404, "user_not_found", "user not found", {"id": user_id})
        return user
    return get_or_create_user(session, DUMMY_USERNAME)

def get_post_score(session: Session, post_id: int) -> int:
    score = session.exec(
        select(func.coalesce(func.sum(PostVote.value), 0)).where(PostVote.post_id == post_id)
    ).one()
    return int(score or 0)

v1 = APIRouter(prefix="/v1")

@v1.get("/posts", response_model=PostListResponse)
def list_posts(
    limit: int = Query(20, ge=1, le=100),
    cursor: Optional[int] = Query(None, ge=1),
    sort: str = Query("new"),
    order: str = Query("desc"),
    community_filter: Optional[int] = Query(None, alias="filter[community_id]"),
    author_filter: Optional[int] = Query(None, alias="filter[author_id]"),
    q: Optional[str] = None,
    include: Optional[str] = None,
    fields_posts: Optional[str] = Query(None, alias="fields[posts]"),
):
    if sort not in ("new", "top", "hot"):
        raise_error(400, "invalid_sort", "sort must be new, top, or hot")
    if order not in ("asc", "desc"):
        raise_error(400, "invalid_order", "order must be asc or desc")

    _ = include
    _ = fields_posts

    with Session(engine) as session:
        score_expr = post_score_expr()
        stmt = select(Post, score_expr).outerjoin(PostVote, Post.id == PostVote.post_id)
        stmt = stmt.where(Post.deleted_at == None)
        if community_filter is not None:
            stmt = stmt.where(Post.community_id == community_filter)
        if author_filter is not None:
            stmt = stmt.where(Post.author_user_id == author_filter)
        if q:
            stmt = stmt.where(or_(Post.title.contains(q), Post.body.contains(q)))

        stmt = stmt.group_by(Post.id)

        if sort == "top":
            order_expr = score_expr.desc() if order == "desc" else score_expr.asc()
        else:
            order_expr = Post.created_at.desc() if order == "desc" else Post.created_at.asc()
        stmt = stmt.order_by(order_expr)

        if cursor and sort in ("new", "hot"):
            if order == "desc":
                stmt = stmt.where(Post.id < cursor)
            else:
                stmt = stmt.where(Post.id > cursor)

        stmt = stmt.limit(limit + 1)
        rows = session.exec(stmt).all()
        has_more = len(rows) > limit
        items = rows[:limit]
        data = [post_to_out(post, score) for post, score in items]
        next_cursor = str(items[-1][0].id) if has_more and items else None
        return {"data": data, "meta": {"next_cursor": next_cursor, "has_more": has_more}}

@v1.post("/posts", response_model=PostCreateResponse)
def create_post(payload: PostCreateIn):
    with Session(engine) as session:
        community = session.get(Community, payload.commu        if payload.community_id is None and not payload.community_name:
            raise_error(400, "missing_community", "community_id or community_name is required")

        if payload.community_id is not None:
            community = session.get(Community, payload.community_id)
            if not community:
                raise_error(404, "community_not_found", "community not found", {"id": payload.community_id})
        else:
            owner_username = payload.author_username or DUMMY_USERNAME
            community = get_or_create_community(session, payload.community_name, owner_username)

        if payload.author_id is not None:
            user = session.get(User, payload.author_id)
            if not user:
                raise_error(404, "user_not_found", "user not found", {"id": payload.author_id})
        elif payload.author_username:
            user = get_or_create_user(session, payload.author_username)
        else:
            user = get_or_create_user(session, DUMMY_USERNAME)
.id,
            author_user_id=user.id,
            title=payload.title,
            body=payload.body,
            image_url=payload.image_url,
            created_at=datetime.utcnow(),
        )
        session.add(post)
        session.commit()
        session.refresh(post)
        return {"data": {"id": post.id, "created_at": post.created_at}}

@v1.get("/posts/{post_id}", response_model=PostResponse)
def get_post(post_id: int):
    with Session(engine) as session:
        score_expr = post_score_expr()
        stmt = (
            select(Post, score_expr)
            .outerjoin(PostVote, Post.id == PostVote.post_id)
            .where(Post.id == post_id, Post.deleted_at == None)
            .group_by(Post.id)
        )
        row = session.exec(stmt).first()
        if not row:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})
        post, score = row
        return {"data": post_to_out(post, score)}

@v1.patch("/posts/{post_id}", response_model=PostResponse)
def update_post(post_id: int, payload: PostUpdateIn):
    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post or post.deleted_at is not None:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})

        if payload.title is not None:
            post.title = payload.title
        if payload.body is not None:
            post.body = payload.body
        if payload.image_url is not None:
            post.image_url = payload.image_url

        post.edited_at = datetime.utcnow()
        session.add(post)
        session.commit()
        session.refresh(post)
        score = get_post_score(session, post_id)
        return {"data": post_to_out(post, score)}

@v1.delete("/posts/{post_id}", response_model=DeleteResponse)
def delete_post(post_id: int):
    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post or post.deleted_at is not None:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})

        post.deleted_at = datetime.utcnow()
        session.add(post)
        session.commit()
        return {"data": {"id": post_id}}

@v1.put("/posts/{post_id}/vote", response_model=VoteResponse)
def vote_post(post_id: int, payload: VoteIn):
    if payload.value not in (-1, 1):
        raise_error(400, "invalid_vote", "value must be 1 or -1")

    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post or post.deleted_at is not None:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})

        user = get_user_for_action(session, payload.user_id)
        vote = session.get(PostVote, (post_id, user.id))
        if vote:
            vote.value = payload.value
            vote.created_at = datetime.utcnow()
        else:
            vote = PostVote(post_id=post_id, user_id=user.id, value=payload.value, created_at=datetime.utcnow())
            session.add(vote)
        session.commit()
        return {"data": {"post_id": post_id, "user_id": user.id, "value": payload.value}}

@v1.delete("/posts/{post_id}/vote", response_model=VoteResponse)
def clear_vote(post_id: int, user_id: Optional[int] = Query(None)):
    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post or post.deleted_at is not None:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})

        user = get_user_for_action(session, user_id)
        vote = session.get(PostVote, (post_id, user.id))
        if vote:
            session.delete(vote)
            session.commit()
        return {"data": {"post_id": post_id, "user_id": user.id, "value": 0}}

@v1.get("/posts/{post_id}/comments", response_model=CommentListResponse)
def list_comments(
    post_id: int,
    limit: int = Query(50, ge=1, le=100),
    cursor: Optional[int] = Query(None, ge=1),
    order: str = Query("asc"),
):
    if order not in ("asc", "desc"):
        raise_error(400, "invalid_order", "order must be asc or desc")

    with Session(engine) as session:
        post = session.get(Post, post_id)
        if not post or post.deleted_at is not None:
            raise_error(404, "post_not_found", "post not found", {"id": post_id})

        stmt = select(Comment).where(Comment.post_id == post_id, Comment.deleted_at == None)
        if cursor:
            if order == "desc":
                stmt = stmt.where(Comment.id < cursor)
            else:
                stmt = stmt.where(Comment.id > cursor)
        stmt = stmt.order_by(Comment.created_at.desc() if order == "desc" else Comment.created_at.asc())
        stmt = stmt.limit(limit + 1)
        rows = session.exec(stmt).all()
        has_more = len(rows) > limit
        items = rows[:limit]
        data = [
            CommentOut(
                id=comment.id,
                post_id=comment.post_id,
                author_id=comment.author_user_id,
                parent_comment_id=comment.parent_comment_id,
                body=comment.body,
                created_at=comment.created_at,
            )
            for comment in items
        ]
        next_cursor = str(items[-1].id) if has_more and items else None
        return {"data": data, "meta": {"next_cursor": next_cursor, "has_more": has_more}}

@v1.post("/posts/batch", response_model=PostBatchResponse)
def batch_get_posts(payload: PostBatchIn):
    with Session(engine) as session:
        score_expr = post_score_expr()
        stmt = (
            select(Post, score_expr)
            .outerjoin(PostVote, Post.id == PostVote.post_id)
            .where(Post.id.in_(payload.ids), Post.deleted_at == None)
            .group_by(Post.id)
        )
        rows = session.exec(stmt).all()
        post_map = {post.id: (post, score) for post, score in rows}
        data = [post_to_out(post_map[post_id][0], post_map[post_id][1]) for post_id in payload.ids if post_id in post_map]
        return {"data": data}

app.include_router(v1)

  session.commit()
    session.refresh(c)
    return c

# ---- 1) GET /posts -> 5 random posts ----

@app.get("/posts")
def get_5_random_posts():
    with Session(engine) as session:
        posts = session.exec(select(Post)).all()
        if not posts:
            return []
        sample = random.sample(posts, k=min(5, len(posts)))

        # super simple response
        return [
            {
                "id": p.id,
                "community_id": p.community_id,
                "author_user_id": p.author_user_id,
                "title": p.title,
                "body": p.body,
                "image_url": p.image_url,
                "created_at": p.created_at,
            }
            for p in sample
        ]

# ---- 2) POST /posts/new -> create post by usernames + community names ----

@app.post("/posts/new")
def new_post(payload: dict):
    # expects: { "username": "...", "community": "...", "title": "...", "body": "...?", "image_url": "...?" }
    username = payload.get("username")
    community_name = payload.get("community")
    title = payload.get("title")

    if not username or not community_name or not title:
        raise HTTPException(400, "username, community, title are required")

    with Session(engine) as session:
        user = get_or_create_user(session, username)
        community = get_or_create_community(session, community_name, username)

        post = Post(
            community_id=community.id,
            author_user_id=user.id,
            title=title,
            body=payload.get("body"),
            image_url=payload.get("image_url"),
            created_at=datetime.utcnow(),
        )
        session.add(post)
        session.commit()
        session.refresh(post)

        return {"id": post.id}

# ---- 3) POST /posts/{id}/thumb -> vote with dummy user ----

@app.post("/posts/{post_id}/thumb")
def thumb(post_id: int, payload: dict):
    # expects: { "value": 1 } or { "value": -1 }
    value = payload.get("value")
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
            vote.created_at = datetime.utcnow()
        else:
            vote = PostVote(post_id=post_id, user_id=dummy.id, value=value, created_at=datetime.utcnow())
            session.add(vote)

        session.commit()
        return {"ok": True, "post_id": post_id, "user": DUMMY_USERNAME, "value": value}

if __name__ == "__main__":
    # Create tables if you want (usually do this in a migration tool instead)
    # SQLModel.metadata.create_all(engine)

    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
