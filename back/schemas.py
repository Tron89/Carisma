from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class PostOut(BaseModel):
    id: int
    community_id: int
    author_user_id: int
    title: str
    body: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime

class PostCreatePayload(BaseModel):
    username: str
    community: str
    title: str
    body: Optional[str] = None
    image_url: Optional[str] = None

class PostCreateResponse(BaseModel):
    id: int

class PostThumbPayload(BaseModel):
    value: int