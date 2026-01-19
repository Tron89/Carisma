from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional

from sqlmodel import Field, Relationship, SQLModel, UniqueConstraint


# ---------- Enums ----------

class UserStatus(str, Enum):
    ACTIVE = "active"
    BANNED = "banned"
    DELETED = "deleted"


class CommunityType(str, Enum):
    PUBLIC = "public"
    RESTRICTED = "restricted"
    PRIVATE = "private"


class CommunityRole(str, Enum):
    OWNER = "owner"
    MOD = "mod"
    MEMBER = "member"
    BANNED = "banned"


# ---------- Tables ----------

class User(SQLModel, table=True):
    __tablename__ = "users"

    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, nullable=False) # unique and can't be only a number (userstr.isdigit())
    email: str = Field(index=True, nullable=False)
    password_hash: str = Field(nullable=False)

    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)

    status: UserStatus = Field(default=UserStatus.ACTIVE, nullable=False)
    status_changed_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)
    banned_reason: Optional[str] = Field(default=None)

    owned_communities: List["Community"] = Relationship(
        back_populates="owner",
        sa_relationship_kwargs={"foreign_keys": "[Community.owner_user_id]"},
    )
    personal_community: Optional["Community"] = Relationship(
        back_populates="personal_user",
        sa_relationship_kwargs={"foreign_keys": "[Community.personal_user_id]"},
    )

    posts: List["Post"] = Relationship(back_populates="author")
    comments: List["Comment"] = Relationship(back_populates="author")

    roles: List["CommunityRoleAssignment"] = Relationship(
        back_populates="user",
        sa_relationship_kwargs={"foreign_keys": "[CommunityRoleAssignment.user_id]"},
        )
    granted_roles: List["CommunityRoleAssignment"] = Relationship(
        back_populates="granted_by",
        sa_relationship_kwargs={"foreign_keys": "[CommunityRoleAssignment.granted_by_user_id]"},
    )

    post_votes: List["PostVote"] = Relationship(back_populates="user")
    comment_votes: List["CommentVote"] = Relationship(back_populates="user")

    __table_args__ = (
        UniqueConstraint("username", name="uq_users_username"),
        UniqueConstraint("email", name="uq_users_email"),
    )


class Community(SQLModel, table=True):
    __tablename__ = "communities"

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True, nullable=False)
    description: Optional[str] = Field(default=None)
    type: CommunityType = Field(default=CommunityType.PUBLIC, nullable=False)

    owner_user_id: int = Field(foreign_key="users.id", nullable=False, index=True)

    is_personal: bool = Field(default=False, nullable=False) # TODO: maybe its not necesary the personal comunity
    personal_user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)

    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)

    deleted_at: Optional[datetime] = Field(default=None, index=True)

    owner: "User" = Relationship(
        back_populates="owned_communities",
        sa_relationship_kwargs={"foreign_keys": "[Community.owner_user_id]"},
    )
    personal_user: Optional["User"] = Relationship(
        back_populates="personal_community",
        sa_relationship_kwargs={"foreign_keys": "[Community.personal_user_id]"},
    )

    posts: List["Post"] = Relationship(back_populates="community")
    roles: List["CommunityRoleAssignment"] = Relationship(back_populates="community")

    __table_args__ = (
        UniqueConstraint("name", name="uq_communities_name"),
        UniqueConstraint("personal_user_id", name="uq_communities_personal_user_id"),
    )


class Post(SQLModel, table=True):
    __tablename__ = "posts"

    id: Optional[int] = Field(default=None, primary_key=True)
    community_id: int = Field(foreign_key="communities.id", nullable=False, index=True)
    author_user_id: int = Field(foreign_key="users.id", nullable=False, index=True)

    title: str = Field(nullable=False)
    body: Optional[str] = Field(default=None)

    image_url: Optional[str] = Field(default=None)

    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False, index=True)
    edited_at: Optional[datetime] = Field(default=None)
    deleted_at: Optional[datetime] = Field(default=None, index=True)

    community: "Community" = Relationship(back_populates="posts")
    author: "User" = Relationship(back_populates="posts")

    comments: List["Comment"] = Relationship(back_populates="post")
    votes: List["PostVote"] = Relationship(back_populates="post")

class Comment(SQLModel, table=True):
    __tablename__ = "comments"

    id: Optional[int] = Field(default=None, primary_key=True)
    post_id: int = Field(foreign_key="posts.id", nullable=False, index=True)
    author_user_id: int = Field(foreign_key="users.id", nullable=False, index=True)

    parent_comment_id: Optional[int] = Field(default=None, foreign_key="comments.id", index=True)

    body: str = Field(nullable=False)

    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False, index=True)
    edited_at: Optional[datetime] = Field(default=None)
    deleted_at: Optional[datetime] = Field(default=None, index=True)

    post: "Post" = Relationship(back_populates="comments")
    author: "User" = Relationship(back_populates="comments")

    parent: Optional["Comment"] = Relationship(
        back_populates="children",
        sa_relationship_kwargs={"remote_side": "Comment.id"},
    )
    children: List["Comment"] = Relationship(back_populates="parent")

    votes: List["CommentVote"] = Relationship(back_populates="comment")


class CommunityRoleAssignment(SQLModel, table=True):
    __tablename__ = "community_roles"

    community_id: int = Field(foreign_key="communities.id", primary_key=True)
    user_id: int = Field(foreign_key="users.id", primary_key=True)

    role: CommunityRole = Field(default=CommunityRole.MEMBER, nullable=False)
    granted_by_user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)

    community: "Community" = Relationship(back_populates="roles")
    user: "User" = Relationship(
        back_populates="roles",
        sa_relationship_kwargs={"foreign_keys": "[CommunityRoleAssignment.user_id]"},
        )
    granted_by: Optional["User"] = Relationship(
        back_populates="granted_roles",
        sa_relationship_kwargs={"foreign_keys": "[CommunityRoleAssignment.granted_by_user_id]"},
    )


class PostVote(SQLModel, table=True):
    __tablename__ = "post_votes"

    post_id: int = Field(foreign_key="posts.id", primary_key=True)
    user_id: int = Field(foreign_key="users.id", primary_key=True)

    value: int = Field(nullable=False)  # +1 / -1
    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)

    post: "Post" = Relationship(back_populates="votes")
    user: "User" = Relationship(back_populates="post_votes")


class CommentVote(SQLModel, table=True):
    __tablename__ = "comment_votes"

    comment_id: int = Field(foreign_key="comments.id", primary_key=True)
    user_id: int = Field(foreign_key="users.id", primary_key=True)

    value: int = Field(nullable=False)  # +1 / -1
    created_at: datetime = Field(default_factory=datetime.now(timezone.utc), nullable=False)

    comment: "Comment" = Relationship(back_populates="votes")
    user: "User" = Relationship(back_populates="comment_votes")