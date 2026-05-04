from typing import List

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from schemas.user import UserRead
from database import get_session
from api.v1.deps import get_current_admin_user
from services.admin import AdminService

# Tüm router'ı admin yetkisine bağlayan kilit nokta: dependencies
admin_router = APIRouter(
    prefix="/admin", tags=["admin"], dependencies=[Depends(get_current_admin_user)]
)


# Servisi enjekte etmek için küçük bir dependency (Optional ama temiz kod için iyi)
def get_admin_service(session: AsyncSession = Depends(get_session)) -> AdminService:
    return AdminService(session)


@admin_router.get(
    "/users", response_model=List[UserRead], status_code=status.HTTP_200_OK
)
async def list_all_users(
    skip: int = 0,
    limit: int = 100,
    admin_service: AdminService = Depends(get_admin_service),
):
    """Sistemdeki tüm kullanıcıları sayfalama (pagination) ile listeler."""
    users = await admin_service.get_all_users(skip=skip, limit=limit)
    return users


@admin_router.get(
    "/users/{user_id}", response_model=UserRead, status_code=status.HTTP_200_OK
)
async def get_user_detail_for_admin(
    user_id: int,
    admin_service: AdminService = Depends(get_admin_service),
):
    """
    Belirli bir kullanıcının tüm bilgilerini yönetici ekranı için getirir.
    """
    return await admin_service.get_user_detail(user_id)


@admin_router.patch("/users/{user_id}/toggle-status", response_model=UserRead)
async def toggle_user_status(
    user_id: int,
    admin_service: AdminService = Depends(get_admin_service),
):
    """Bir kullanıcının hesabını dondurur (Banlar) veya aktif eder."""
    return await admin_service.toggle_user_status(user_id)


@admin_router.patch("/users/{user_id}/promote-streamer", response_model=UserRead)
async def promote_user_to_streamer(
    user_id: int,
    admin_service: AdminService = Depends(get_admin_service),
):
    """Kullanıcıya yayın yapma yetkisi verir ve onaylı yayıncı yapar."""
    return await admin_service.promote_to_streamer(user_id)
