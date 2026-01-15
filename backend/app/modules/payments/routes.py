from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.modules.users.models import User
from app.modules.auth.roles import allow_buyer
from app.modules.projects.models import Task, TaskStatus, Project
from app.modules.payments.models import Payment

router = APIRouter()

@router.post("/{task_id}")
async def pay_for_task(
    task_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_buyer)
):
    task = await db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    project = await db.get(Project, task.project_id)
    if project.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your project")
    
    if task.status != TaskStatus.SUBMITTED:
        raise HTTPException(status_code=400, detail="Task not ready for payment or already paid")
    
    amount = task.hourly_rate * (task.time_spent or 0)
    
    payment = Payment(task_id=task.id, amount=amount)
    db.add(payment)
    
    task.status = TaskStatus.PAID
    
    await db.commit()
    return {"message": "Payment successful", "amount_paid": amount}
