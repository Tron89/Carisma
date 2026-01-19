from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from models import UserStatus, CommunityType


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

#---- User Schemas ----
class UserBaseOut(BaseModel):
    id: int
    username: str
    created_at: datetime
    status: UserStatus

class UserPrivateOut(UserBaseOut):
    email: str
    status_changed_at: datetime
    banned_reason: str | None = None

class CommunityOut(BaseModel):
    id: int
    name: str
    title: str
    description: str | None = None
    type: CommunityType
    owner_user_id: int
    is_personal: bool
    personal_user_id: int | None = None
    created_at: datetime

class CommunityCreatePayload(BaseModel):
    name: str
    owner_username: str
    title: str | None = None
    description: str | None = None
    type: CommunityType = CommunityType.PUBLIC

class UserCreatePayload(BaseModel):
    username: str
    email: str
    password: str

class LoginPayload(BaseModel):
    username: str
    password: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPrivateOut
