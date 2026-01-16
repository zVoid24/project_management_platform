from pydantic import BaseModel
from datetime import datetime
from typing import List

class ProjectBase(BaseModel):
    title: str
    description: str

class ProjectCreate(ProjectBase):
    pass

class ProjectRead(ProjectBase):
    id: int
    owner_id: int
    created_at: datetime
    task_count: int = 0

    class Config:
        from_attributes = True
