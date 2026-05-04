from typing import Annotated, List
from fastapi import APIRouter, Depends, status, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from api.v1.deps import get_current_user, get_session, get_notification_service
from models import User
from schemas.notification import NotificationRead
from services.notifications import NotificationService

router = APIRouter()

@router.get("/", response_model=List[NotificationRead])
async def get_notifications(
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[NotificationService, Depends(get_notification_service)],
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Kullanıcının bildirim geçmişini sayfalı olarak getirir.
    """
    return await service.get_history(current_user.id, limit, offset)

@router.patch("/{notif_id}/read", status_code=status.HTTP_204_NO_CONTENT)
async def mark_notification_as_read(
    notif_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[NotificationService, Depends(get_notification_service)],
    session: Annotated[AsyncSession, Depends(get_session)],
):
    """
    Tekil bir bildirimi okundu olarak işaretler.
    """
    # Yetki kontrolü (Bildirim gerçekten bu kullanıcıya mı ait?)
    notification = await service.repository.get_by_id(notif_id)
    if not notification or notification.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Bildirim bulunamadı.")
        
    await service.repository.update(notif_id, {"is_read": True})
    await session.commit()

@router.patch("/read-all", status_code=status.HTTP_204_NO_CONTENT)
async def mark_all_notifications_as_read(
    current_user: Annotated[User, Depends(get_current_user)],
    service: Annotated[NotificationService, Depends(get_notification_service)],
    session: Annotated[AsyncSession, Depends(get_session)],
):
    """
    Kullanıcının tüm okunmamış bildirimlerini okundu olarak işaretler.
    """
    await service.repository.mark_all_as_read(current_user.id)
    await session.commit()
