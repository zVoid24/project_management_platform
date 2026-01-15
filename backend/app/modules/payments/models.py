from sqlalchemy import Float, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from datetime import datetime

class Payment(Base):
    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    task_id: Mapped[int] = mapped_column(ForeignKey("tasks.id"), unique=True)
    amount: Mapped[float] = mapped_column(Float)
    payment_date: Mapped[datetime] = mapped_column(default=datetime.utcnow)

    task = relationship("app.modules.projects.models.Task", back_populates="payment")
