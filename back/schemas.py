# schemas.py

from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import datetime

from models import UserStatus, CommunityType

# ---- Payloads ----

class PostCreatePayload(BaseModel):
    community: str = Field(min_length=1, pattern=r".*\D.*")
    title: str = Field(min_length=1)
    body: Optional[str] = Field(default=None, min_length=1)
    image_url: Optional[str] = Field(default=None, min_length=1)

class PostThumbPayload(BaseModel):
    value: int = Field(ge=-1, le=1)
    
class CommunityCreatePayload(BaseModel):
    name: str = Field(min_length=1, pattern=r".*\D.*")
    description: str | None = Field(default=None, min_length=1)
    type: CommunityType = CommunityType.PUBLIC

class UserCreatePayload(BaseModel):
    username: str = Field(min_length=1, pattern=r".*\D.*")
    email: EmailStr = Field(max_length=254)
    password: str = Field(min_length=1)

class LoginPayload(BaseModel):
    username: str = Field(min_length=1, pattern=r".*\D.*")
    password: str = Field(min_length=1)

# ---- Object Schemas ----
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
    description: str | None = None
    type: CommunityType
    owner_user_id: int
    is_personal: bool # TODO: maybe its not necesary the personal comunity
    personal_user_id: int | None = None
    created_at: datetime
    
class PostOut(BaseModel):
    id: int
    community_id: int
    author_user_id: int
    title: str
    body: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime

# ---- Responses ----

class PostCreateResponse(BaseModel):
    id: int

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPrivateOut
