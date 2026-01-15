from pydantic import BaseModel
from typing import Optional
from app.modules.projects.models import TaskStatus

class TaskBase(BaseModel):
    title: str
    description: str
    hourly_rate: float
    assignee_id: int

class TaskCreate(TaskBase):
    project_id: int

class TaskUpdate(BaseModel):
    # For devs to update status and submit work
    status: Optional[TaskStatus] = None
    time_spent: Optional[float] = None

class TaskRead(TaskBase):
    id: int
    project_id: int
    status: TaskStatus
    time_spent: Optional[float] = None
    # solution_file_path should ONLY be visible if PAID or if user is owner/assignee?
    # Actually requirement: "Buyer CANNOT download or view ZIP file... until payment"
    # So we probably shouldn't expose the path directly or check permissions on download.
    
    class Config:
        from_attributes = True
