from pydantic import BaseModel, ConfigDict
from datetime import datetime

from schemas.user import UserBasic

# Ortak alanlar
class StreamBase(BaseModel):
    title: str

# Kullanıcıdan sadece title alırız, room_name'i backend'de biz üreteceğiz
class StreamCreate(StreamBase):
    pass

# Frontend'e dönülecek veri
class StreamResponse(StreamBase):
    id: str
    streamer_id: int
    room_name: str
    is_live: bool
    viewer_count: int
    created_at: datetime
    streamer: UserBasic  # Yayıncı bilgileri buraya eklendi

    # ORM nesnelerini Pydantic modeline dönüştürmek için
    model_config = ConfigDict(from_attributes=True)

class StreamConnectionResponse(BaseModel):
    stream: StreamResponse
    token: str