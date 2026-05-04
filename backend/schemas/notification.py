from enum import Enum
from typing import Any, Dict, Optional
from pydantic import BaseModel, ConfigDict, Field
from datetime import datetime

class NotificationType(str, Enum):
    STREAM_START = "stream_start"
    NEW_FOLLOWER = "new_follower"
    SYSTEM_ALERT = "system_alert"

class NotificationBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    body: str = Field(..., min_length=1, max_length=500)
    data: Dict[str, Any] = Field(default_factory=dict)

class NotificationCreate(NotificationBase):
    user_id: int
    type: NotificationType
    image_url: Optional[str] = None

class NotificationRead(NotificationBase):
    id: int
    user_id: int
    type: NotificationType
    is_read: bool
    created_at: datetime
    image_url: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)

class NotificationEvent(NotificationBase):
    """
    Redis kuyruğuna (Worker'a) gönderilecek olan veri paketi.
    """
    id: int
    user_id: int
    type: NotificationType