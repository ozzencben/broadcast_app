from sqlalchemy import select
from sqlalchemy.orm import joinedload
from sqlalchemy.ext.asyncio import AsyncSession
from models.stream import Stream
from repositories.base import BaseRepository 

class StreamRepository(BaseRepository[Stream]):
    def __init__(self, session: AsyncSession):
        super().__init__(session, Stream)

    async def get_by_id(self, id: str) -> Stream | None:
        stmt = select(self.model).where(self.model.id == id).options(joinedload(self.model.streamer))
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def get_active_streams(self, skip: int = 0, limit: int = 10) -> list[Stream]:
        stmt = (
            select(self.model)
            .where(self.model.is_live.is_(True))  # Daha güvenli filtreleme
            .options(joinedload(self.model.streamer))
            .offset(skip)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def get_by_room_name(self, room_name: str) -> Stream | None:
        stmt = (
            select(self.model)
            .where(self.model.room_name == room_name)
            .options(joinedload(self.model.streamer)) # İŞTE EKLENEN KRİTİK SATIR
        )
        result = await self.session.execute(stmt)
        return result.scalars().first()
    
    async def end_stream(self, room_name: str) -> bool:
        stmt = select(self.model).where(self.model.room_name == room_name)
        result = await self.session.execute(stmt)
        stream = result.scalars().first()
        
        if stream:
            stream.is_live = False
            stream.viewer_count = 0
            await self.session.commit()
            return True
        return False