from services import StreamService
from fastapi import HTTPException, APIRouter, Request, Header, Depends
from sqlalchemy.ext.asyncio import AsyncSession
# TokenKeyProvider yerine TokenVerifier import ediyoruz
from livekit.api import WebhookReceiver, TokenVerifier 
from loguru import logger

from core.config import settings
from database import get_session

router = APIRouter(prefix="/webhooks", tags=["Webhooks"])

# 1. Anahtarları doğrulayıcıyı (verifier) oluşturuyoruz
token_verifier = TokenVerifier(
    settings.LIVEKIT_API_KEY, 
    settings.LIVEKIT_API_SECRET
)

# 2. Receiver'a bu verifier'ı paket olarak veriyoruz
receiver = WebhookReceiver(token_verifier)

@router.post("/livekit")
async def livekit_webhook(
    request: Request,
    authorization: str = Header(None),
    db: AsyncSession = Depends(get_session)
):
    """
    LiveKit'ten gelen bildirimleri dinleyen kapı.
    """
    body = await request.body()
    body_str = body.decode("utf-8")
    
    try:
        auth_token = authorization.encode("utf-8") if authorization else b""
        event = receiver.receive(body_str, auth_token)

        service = StreamService(db)
        await service.handle_webhook_event(event)
        
    except Exception as e:
        logger.error(f"Webhook doğrulama hatası: {e}")
        raise HTTPException(status_code=400, detail=f"Invalid webhook: {str(e)}")
    
    logger.info(f"Doğrulanmış Olay Geldi: {event.event}")
    
    return {"status": "verified"}