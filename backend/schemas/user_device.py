from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import datetime

class DeviceRegister(BaseModel):
    fcm_token: str = Field(..., min_length=10, max_length=255)
    device_type: str = Field(default="android", pattern="^(android|ios|web)$")
    device_model: Optional[str] = Field(None, max_length=100)

class DeviceRead(DeviceRegister):
    id: int
    user_id: int
    last_active: datetime

    model_config = ConfigDict(from_attributes=True)