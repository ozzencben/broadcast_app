import uuid
from livekit.api import AccessToken, VideoGrants
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from schemas.stream import StreamCreate
from models.stream import Stream
from loguru import logger
from sqlalchemy.orm import selectinload

from core.config import settings
from core.websocket_manager import manager
from repositories.stream import StreamRepository

class StreamService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repo = StreamRepository(session)
        self.api_key = settings.LIVEKIT_API_KEY
        self.api_secret = settings.LIVEKIT_API_SECRET

    async def get_active_streams(self, skip: int = 0, limit: int = 10):
        query = (
            select(Stream)
            .where(Stream.is_live == True)
            .options(selectinload(Stream.streamer))
            .offset(skip)
            .limit(limit)
        )
        result = await self.session.execute(query)
        return result.scalars().all()

    def _generate_token(self, room_name: str, identity: str, is_publisher: bool = False) -> str:
        token = AccessToken(
            self.api_key,
            self.api_secret
        )
        token.with_identity(str(identity))
        
        grant = VideoGrants(
            room_join=True,
            room=room_name,
            can_publish=is_publisher,
            can_subscribe=True
        )
        
        token.with_grants(grant)
        
        return token.to_jwt()

    async def start_stream(self, stream_in: StreamCreate, user) -> tuple[Stream, str]:
        # Create a unique room name
        room_name = f"room-{uuid.uuid4().hex[:8]}"
        
        # Create stream entry
        stream_data = stream_in.model_dump()
        stream_data.update({
            "streamer_id": user.id,
            "room_name": room_name,
            "is_live": True
        })
        
        stream = await self.repo.create(stream_data)
        await self.session.commit()
        
        # Streamer bilgisini tazeleyerek (load ederek) dön
        stream = await self.repo.get_by_id(stream.id)
        
        # Generate token for streamer
        token = self._generate_token(
            room_name=room_name,
            identity=user.id,
            is_publisher=True
        )

        await manager.broadcast({
            "type":"NEW_STREAM_STARTED",
            "title": stream_in.title,
            "streamer": user.username
        })
        
        return stream, token

    async def join_stream(self, room_name: str, user) -> tuple[Stream, str]:
        stream = await self.repo.get_by_room_name(room_name)
        
        if not stream or not stream.is_live:
            raise ValueError("Stream not found or has ended.")

        # Generate token for viewer
        token = self._generate_token(
            room_name=room_name,
            identity=user.id,
            is_publisher=False
        )
        return stream, token

    async def end_stream(self, room_name: str, user):
        stream = await self.repo.get_by_room_name(room_name)
        
        if not stream:
            raise ValueError("Stream not found.")
            
        if stream.streamer_id != user.id:
            raise ValueError("You are not authorized to end this stream.")
            
        await self.repo.end_stream(room_name)

        await manager.broadcast({
            "type":"STREAM_ENDED",
            "room_name": room_name,
        })
        
        return True

    async def handle_webhook_event(self, event):
        """
        LiveKit'ten gelen doğrulanmış webhook olaylarını işler.
        """
        room_name = event.room.name
        
        # Olay tipine göre karar ver
        if event.event == "room_finished":
            logger.info(f"Yayın bitti (Otonom): {room_name}")
            await self.repo.end_stream(room_name)
            await manager.broadcast({
                "type": "STREAM_ENDED",
                "room_name": room_name,
            })
            
        elif event.event == "participant_joined":
            # İleride izleyici sayısını artırmak için burayı kullanacağız
            logger.info(f"İzleyici katıldı: {room_name}")
            
        elif event.event == "participant_left":
            # İleride izleyici sayısını azaltmak için burayı kullanacağız
            logger.info(f"İzleyici ayrıldı: {room_name}")