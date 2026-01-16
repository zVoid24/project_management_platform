from pydantic import BaseModel, EmailStr
from app.modules.users.models import UserRole

class UserBase(BaseModel):
    email: EmailStr
    full_name: str | None = None

class UserCreate(UserBase):
    password: str
    role: UserRole

class UserRead(UserBase):
    id: int
    role: UserRole

    class Config:
        from_attributes = True
