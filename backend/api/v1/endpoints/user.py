from typing import Optional
from fastapi import HTTPException
from typing_extensions import Annotated

from fastapi import APIRouter, Depends, File, UploadFile, status, Query, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from schemas.user import UserRead, UserUpdate
from schemas.user_device import DeviceRegister
from models.user import User
from database import get_session
from api.v1.deps import get_current_user
from services.user import UserService
from core.exceptions import UploadOnlyImageException

user_router = APIRouter(
    prefix="/users",
    tags=["users"],
)


def get_user_service(session: AsyncSession = Depends(get_session)) -> UserService:
    return UserService(session)


# =============================================================================
# STATİK ROUTE'LAR — /{dynamic} route'larından ÖNCE tanımlanmalı
# FastAPI route'ları yukarıdan aşağıya sırayla eşleştirir.
# /me, /search gibi sabit yollar /{user_id}'den önce gelmelidir.
# =============================================================================

@user_router.get("/search", response_model=list[UserRead])
async def search_users_endpoint(
    q: str = Query("", description="Arama metni"),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    user_service: UserService = Depends(get_user_service),
):
    """Keşfet ekranı için kullanıcı arama endpoint'i."""
    return await user_service.search_users(
        query=q, current_user_id=current_user.id, skip=skip, limit=limit
    )


@user_router.get("/me", response_model=UserRead, status_code=status.HTTP_200_OK)
async def read_current_user(
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Sisteme giriş yapmış olan kullanıcının profil detaylarını getirir."""
    return current_user


@user_router.patch("/me", response_model=UserRead, status_code=status.HTTP_200_OK)
async def update_current_user(
    user_in: UserUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Kullanıcının profil bilgilerini günceller."""
    return await user_service.update_profile(current_user=current_user, user_in=user_in)


@user_router.delete("/me", status_code=status.HTTP_200_OK)
async def deactivate_current_user(
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Kullanıcının hesabını dondurur."""
    return await user_service.deactivate_account(current_user=current_user)


@user_router.post("/me/image")
async def upload_my_image(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    current_user: Annotated[User, Depends(get_current_user)] = None,
    user_service: UserService = Depends(get_user_service),
):
    """Kullanıcı profil resmi yükler."""
    if not file.content_type.startswith("image/"):
        raise UploadOnlyImageException()

    return await user_service.update_profile_image(
        user_id=current_user.id,
        file=file,
        background_tasks=background_tasks,
    )


@user_router.post("/me/devices", status_code=status.HTTP_204_NO_CONTENT)
async def register_device_endpoint(
    payload: DeviceRegister,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """
    Kullanıcının FCM token ve cihaz bilgilerini (Upsert) kaydeder.
    Idempotent yapıdadır.
    """
    await user_service.register_user_device(user_id=current_user.id, payload=payload)


# =============================================================================
# DİNAMİK ROUTE'LAR — /{id} içerenlerin hepsi aşağıda
# =============================================================================

@user_router.get("/{user_id}", response_model=UserRead)
async def get_user_profile_endpoint(
    user_id: int,
    current_user: User = Depends(get_current_user),
    user_service: UserService = Depends(get_user_service),
):
    """Herhangi bir kullanıcının profilini getirir (is_following dahil)."""
    return await user_service.get_user_profile(
        user_id=user_id, current_user_id=current_user.id
    )


@user_router.post("/{streamer_id}/follow", status_code=status.HTTP_200_OK)
async def follow_streamer_endpoint(
    streamer_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Belirtilen ID'ye sahip bir yayıncıyı takip eder."""
    streamer = await user_service.user_repo.get_by_id(streamer_id)
    if not streamer:
        raise HTTPException(status_code=404, detail="Yayıncı bulunamadı")

    return await user_service.follow_streamer(
        current_user=current_user, streamer=streamer
    )


@user_router.post("/{streamer_id}/unfollow", status_code=status.HTTP_200_OK)
async def unfollow_streamer_endpoint(
    streamer_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Belirtilen ID'ye sahip bir yayıncıyı takipten çıkar."""
    return await user_service.unfollow_streamer(
        follower_id=current_user.id, streamer_id=streamer_id
    )


@user_router.get("/{streamer_id}/followers", response_model=list[UserRead])
async def get_follower_list_endpoint(
    streamer_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Yayıncının takipçilerini getirir."""
    return await user_service.get_follower_list_for_streamer(
        streamer_id=streamer_id, current_user_id=current_user.id
    )


@user_router.get("/{user_id}/following", response_model=list[UserRead])
async def get_following_list_endpoint(
    user_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    user_service: UserService = Depends(get_user_service),
):
    """Kullanıcının takip ettiği yayıncıları getirir."""
    return await user_service.get_followed_list_for_user(
        user_id=user_id, current_user_id=current_user.id
    )
