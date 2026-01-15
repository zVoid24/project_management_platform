from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.modules.users import crud, schemas
from app.modules.auth.deps import get_current_active_user

router = APIRouter()

@router.post("/", response_model=schemas.UserRead)
async def create_user(
    user: schemas.UserCreate,
    db: AsyncSession = Depends(get_db)
):
    db_user = await crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return await crud.create_user(db=db, user=user)

@router.get("/me", response_model=schemas.UserRead)
async def read_users_me(
    current_user: schemas.UserRead = Depends(get_current_active_user)
):
    return current_user

@router.get("/developers", response_model=list[schemas.UserRead])
async def list_developers(
    db: AsyncSession = Depends(get_db)
    # In a real app, restrict this to Admin/Buyer
):
    from app.modules.users.models import UserRole
    return await crud.get_users_by_role(db, UserRole.DEVELOPER)
