from typing import Any, Dict
from arq.connections import RedisSettings
from core.config import settings
from database import AsyncSessionLocal
from services.firebase_service import firebase_service
from schemas.notification import NotificationEvent
from repositories.user import UserRepository

async def startup(ctx: Dict[str, Any]) -> None:
    """Worker ayağa kalkarken paylaşılan kaynakları hazırlar."""
    ctx["db_factory"] = AsyncSessionLocal
    # Firebase Service singleton olduğu için import anında init olur.

async def notify_user_job(ctx: Dict[str, Any], event_dict: Dict[str, Any]) -> None:
    """
    Kuyruktan gelen bildirimi işler. 
    Token cleanup logic: Geçersiz tokenları DB'den temizler.
    """
    event = NotificationEvent.model_validate(event_dict)
    
    async with ctx["db_factory"]() as session:
        user_repo = UserRepository(session)
        tokens = await user_repo.get_user_fcm_tokens(event.user_id)
        
        if not tokens:
            return

        response = await firebase_service.send_multicast(event, tokens)
        
        # Hatalı tokenların tespiti ve temizliği
        if response.failure_count > 0:
            invalid_tokens = [
                tokens[i] for i, res in enumerate(response.responses) 
                if not res.success and res.exception.code in ["unregistered-token", "invalid-argument"]
            ]
            if invalid_tokens:
                await user_repo.remove_user_fcm_tokens(invalid_tokens)
                await session.commit()

class WorkerSettings:
    functions = [notify_user_job]
    on_startup = startup
    redis_settings = RedisSettings(host=settings.REDIS_HOST, port=settings.REDIS_PORT)