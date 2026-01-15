from pydantic import BaseModel

class AdminStats(BaseModel):
    total_projects: int
    total_tasks: int
    completed_tasks: int
    total_payments_received: float
    pending_payments: int
    total_developer_hours: float
    revenue_generated: float
    total_buyers: int
    total_developers: int
