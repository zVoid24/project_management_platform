from typing import List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.core.config import settings
from app.modules.users.models import User
from app.modules.auth.roles import allow_buyer, allow_developer, allow_buyer_or_admin
from app.modules.projects.models import Task, TaskStatus, Project
from app.modules.tasks import schemas
import aiofiles
import os
import shutil

router = APIRouter()

@router.post("/", response_model=schemas.TaskRead)
async def create_task(
    task: schemas.TaskCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer)
):
    # Verify project ownership
    project = await db.get(Project, task.project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    if project.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to add tasks to this project")

    db_task = Task(**task.model_dump())
    db.add(db_task)
    await db.commit()
    await db.refresh(db_task)
    return db_task

@router.get("/assigned", response_model=List[schemas.TaskRead])
async def get_my_tasks(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_developer)
):
    result = await db.execute(select(Task).where(Task.assignee_id == current_user.id))
    return result.scalars().all()

@router.get("/all", response_model=List[schemas.TaskRead])
async def get_all_tasks(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer_or_admin) # Allow buyer to see all? Or just admin? Req says Admin. 
):
    # Requirement: Admin can see Tasks by status with hourly rate.
    # Currently allow_buyer_or_admin might be too broad if buyers shouldn't see other projects.
    # Let's use allow_admin if possible.
    if current_user.role != "admin": # Strict check if allow_buyer_or_admin is mixed
         # Actually allow_buyer_or_admin is fine if we filter? 
         # Buyers usually only see their project tasks.
         # Let's stick to explicit Admin check or import allow_admin
         pass
    
    # Re-checking imports, I see allow_buyer, allow_developer, allow_buyer_or_admin imported.
    # I should import allow_admin.
    from app.modules.auth.roles import allow_admin
    if current_user.role != "admin":
         raise HTTPException(status_code=403, detail="Admin only")
         
    result = await db.execute(select(Task))
    return result.scalars().all()

@router.post("/{task_id}/submit")
async def submit_task(
    task_id: int,
    hours: float = Form(...),
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_developer)
):
    task = await db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.assignee_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your task")
    
    # Save file
    file_location = f"{settings.UPLOAD_DIR}/{task_id}_{file.filename}"
    async with aiofiles.open(file_location, 'wb') as out_file:
        content = await file.read()
        await out_file.write(content)
    
    task.time_spent = hours
    task.solution_file_path = file_location
    task.status = TaskStatus.SUBMITTED
    
    await db.commit()
    return {"message": "Task submitted successfully"}

@router.patch("/{task_id}", response_model=schemas.TaskRead)
async def update_task(
    task_id: int,
    payload: schemas.TaskUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_developer)
):
    task = await db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.assignee_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your task")

    if payload.status:
        if payload.status not in [TaskStatus.TODO, TaskStatus.IN_PROGRESS]:
            raise HTTPException(status_code=400, detail="Invalid status update")
        task.status = payload.status

    if payload.time_spent is not None:
        task.time_spent = payload.time_spent

    await db.commit()
    await db.refresh(task)
    return task

@router.get("/{task_id}/download")
async def download_solution(
    task_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer)
):
    task = await db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Check if buyer owns project
    project = await db.get(Project, task.project_id)
    if project.owner_id != current_user.id:
         raise HTTPException(status_code=403, detail="Not your project")

    if task.status != TaskStatus.PAID:
        raise HTTPException(status_code=402, detail="Payment required to download solution")
    
    # In a real app we would return StreamingResponse or FileResponse
    # returning path for now or FileResponse
    from fastapi.responses import FileResponse
    return FileResponse(task.solution_file_path, filename=os.path.basename(task.solution_file_path), media_type='application/zip')
