from datetime import datetime
from sqlalchemy import String, Boolean, ForeignKey, JSON, DateTime, func, Index
from sqlalchemy.orm import Mapped, mapped_column
from models.base_model import AbstractBase

class Notification(AbstractBase):
    __tablename__ = "notifications"
    
    # Inbox sorgularını optimize etmek için composite index
    __table_args__ = (
        Index("ix_notifications_user_is_read", "user_id", "is_read"),
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), 
        index=True, 
        nullable=False
    )
    type: Mapped[str] = mapped_column(String(50), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(String(500), nullable=False)
    image_url: Mapped[str] = mapped_column(String(500), nullable=True)
    data: Mapped[dict] = mapped_column(JSON, default=dict, server_default="{}")
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now(),
        nullable=False
    )

    __mapper_args__ = {"eager_defaults": True}