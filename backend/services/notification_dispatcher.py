from typing import Optional
from arq import create_pool, ArqRedis
from arq.connections import RedisSettings
from core.config import settings
from schemas.notification import NotificationEvent

class NotificationDispatcher:
    """
    Handles enqueuing notification tasks into Redis for background processing.
    """
    def __init__(self) -> None:
        self.redis_settings = RedisSettings(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT
        )
        self.pool: Optional[ArqRedis] = None

    async def get_pool(self) -> ArqRedis:
        """Havuz yoksa oluşturur, varsa mevcut olanı döner."""
        if self.pool is None:
            self.pool = await create_pool(self.redis_settings)
        return self.pool

    async def close(self) -> None:
        """Havuzu kapatır."""
        if self.pool:
            await self.pool.close()
            self.pool = None

    async def dispatch(self, event: NotificationEvent) -> None:
        """
        Enqueues a 'notify_user_job' to be picked up by the Arq worker.
        """
        redis = await self.get_pool()
        
        await redis.enqueue_job(
            "notify_user_job", 
            event.model_dump()
        )

# Dependency Injection için instance oluşturuyoruz
notification_dispatcher = NotificationDispatcher()