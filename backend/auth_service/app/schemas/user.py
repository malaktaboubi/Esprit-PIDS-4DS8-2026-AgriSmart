from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

# 1. Base properties every user has
class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    region: Optional[str] = None
    role: Optional[str] = "farmer"  # "admin", "consultant", or "farmer"

# 2. Schema for creating a new user (requires password)
class UserCreate(UserBase):
    password: str

# 3. Schema for responding with user data (NEVER include the password)
class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True  # Tells Pydantic to read data even if it's not a dict (like a SQLAlchemy model)


class UserRoleAccessUpdate(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None
