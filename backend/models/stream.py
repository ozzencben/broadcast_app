import uuid
from typing import TYPE_CHECKING
from sqlalchemy import String, Boolean, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from models.base_model import AbstractBase

if TYPE_CHECKING:
    from models.user import User

class Stream(AbstractBase):
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    streamer_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))

    
    room_name: Mapped[str] = mapped_column(String, unique=True, index=True) 
    title: Mapped[str] = mapped_column(String)
    
    is_live: Mapped[bool] = mapped_column(Boolean, default=True)
    viewer_count: Mapped[int] = mapped_column(Integer, default=0)

    streamer: Mapped["User"] = relationship(back_populates="streams")