from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.modules.users.models import User
from app.modules.auth.roles import allow_buyer
from app.modules.projects import models, schemas
# Import Task schemas for the response model
from app.modules.tasks.schemas import TaskRead

router = APIRouter()

@router.post("/", response_model=schemas.ProjectRead)
async def create_project(
    project: schemas.ProjectCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer)
):
    db_project = models.Project(**project.model_dump(), owner_id=current_user.id)
    db.add(db_project)
    await db.commit()
    await db.refresh(db_project)
    return db_project

@router.get("/", response_model=List[schemas.ProjectRead])
async def list_projects(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer) # Buyers see their projects. 
    # Logic might differ for Admin/Developer. 
    # For now, let's assume this endpoint is for buyers to see their projects.
):
    result = await db.execute(select(models.Project).where(models.Project.owner_id == current_user.id))
    return result.scalars().all()

@router.get("/{project_id}/tasks", response_model=List[TaskRead])
async def list_project_tasks(
    project_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer)
):
    project = await db.get(models.Project, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    if project.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your project")
        
    result = await db.execute(select(models.Task).where(models.Task.project_id == project_id))
    return result.scalars().all()
