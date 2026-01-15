from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.core.database import get_db
from app.modules.users.models import User
from app.modules.auth.roles import allow_admin
from app.modules.projects.models import Project, Task, TaskStatus
from app.modules.payments.models import Payment
from app.modules.stats.schemas import AdminStats

router = APIRouter()

@router.get("/", response_model=AdminStats)
async def get_admin_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(allow_admin)
):
    # Total projects
    projects_res = await db.execute(select(func.count(Project.id)))
    total_projects = projects_res.scalar() or 0
    
    # Total tasks
    tasks_res = await db.execute(select(func.count(Task.id)))
    total_tasks = tasks_res.scalar() or 0
    
    # Completed tasks (Assuming PAID or SUBMITTED? User said "Completed tasks")
    # Let's count tasks that are finished by dev (SUBMITTED/PAID).
    completed_res = await db.execute(select(func.count(Task.id)).where(Task.status.in_([TaskStatus.SUBMITTED, TaskStatus.PAID])))
    completed_tasks = completed_res.scalar() or 0
    
    # Total payments
    payments_res = await db.execute(select(func.sum(Payment.amount)))
    total_payments_received = payments_res.scalar() or 0.0
    
    # Pending payments (Submitted but not Paid)
    pending_res = await db.execute(select(Task).where(Task.status == TaskStatus.SUBMITTED))
    pending_tasks = pending_res.scalars().all()
    # Calculate expected amount
    pending_amount = sum(t.hourly_rate * (t.time_spent or 0) for t in pending_tasks)
    
    # Total hours
    hours_res = await db.execute(select(func.sum(Task.time_spent)))
    total_developer_hours = hours_res.scalar() or 0.0
    
    # User stats
    buyers_res = await db.execute(select(func.count(User.id)).where(User.role == "buyer"))
    total_buyers = buyers_res.scalar() or 0

    developers_res = await db.execute(select(func.count(User.id)).where(User.role == "developer"))
    total_developers = developers_res.scalar() or 0
    
    return AdminStats(
        total_projects=total_projects,
        total_tasks=total_tasks,
        completed_tasks=completed_tasks,
        total_payments_received=total_payments_received,
        pending_payments=len(pending_tasks), 
        total_developer_hours=total_developer_hours,
        revenue_generated=total_payments_received,
        total_buyers=total_buyers,
        total_developers=total_developers
    )
