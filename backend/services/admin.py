from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from models.user import User
from repositories.user import UserRepository
from core.exceptions import UserNotFoundException


class AdminService:
    """
    Yönetici işlemlerinin (iş kurallarının) yürütüldüğü servis katmanı.
    Veritabanı işlemleri için UserRepository kullanır.
    """

    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)

    async def get_all_users(self, skip: int = 0, limit: int = 100) -> list[User]:
        """Sistemdeki tüm kullanıcıları sayfalama ile getirir."""
        return await self.user_repo.get_all(skip=skip, limit=limit)

    async def get_user_detail(self, user_id: int) -> User:
        """
        Yöneticinin bir kullanıcının tüm detaylarını (hassas veriler dahil)
        görebilmesini sağlar.
        """
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise UserNotFoundException()
        return user

    async def toggle_user_status(self, user_id: int) -> User:
        """
        Kullanıcının aktiflik durumunu tersine çevirir. (Ban / Unban)
        Eğer kullanıcı aktifse pasif yapar, pasifse aktif yapar.
        """
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Kullanıcı bulunamadı."
            )

        # Durumu tersine çevir
        user.is_active = not user.is_active

        # UserRepository'deki update metodunu kullanıyoruz
        updated_user = await self.user_repo.update(
            id=user_id, obj_data={"is_active": user.is_active}
        )
        return updated_user

    async def promote_to_streamer(self, user_id: int) -> User:
        """
        Bir kullanıcıyı doğrudan yayıncı yapar ve hesabını onaylar.
        """
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Kullanıcı bulunamadı."
            )

        if user.is_streamer and user.is_verified_streamer:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Kullanıcı zaten onaylı bir yayıncı.",
            )

        updated_user = await self.user_repo.update(
            id=user_id, obj_data={"is_streamer": True, "is_verified_streamer": True}
        )
        return updated_user
