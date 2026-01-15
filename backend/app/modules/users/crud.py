from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.modules.users.models import User
from app.modules.users.schemas import UserCreate
from app.core.security import get_password_hash

async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(select(User).where(User.email == email))
    return result.scalars().first()

async def create_user(db: AsyncSession, user: UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = User(email=user.email, hashed_password=hashed_password, role=user.role)
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)

async def get_users_by_role(db: AsyncSession, role: str):
    result = await db.execute(select(User).where(User.role == role))
    return result.scalars().all()
