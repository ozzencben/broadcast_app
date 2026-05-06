from typing import Optional
from schemas.user_device import DeviceRegister
from fastapi import BackgroundTasks, HTTPException, status, UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from loguru import logger

from models.user import User
from schemas.user import UserUpdate
from repositories.user import UserRepository
from services.cloudinary_service import CloudinaryService
from core.exceptions import (
    UserNotFoundException,
    UsernameAlreadyExistsException,
    EmailAlreadyExistsException,
    NotFollowYourselfException,
)
from schemas.notification import NotificationCreate, NotificationType
from services.notifications import NotificationService
from core.websocket_manager import manager


class UserService:
    """
    Kullanıcının kendi hesabı ve diğer kullanıcılarla olan (takip vb.)
    işlemlerini yürüten servis katmanı.
    """

    def __init__(self, session: AsyncSession):
        self.session = session
        self.user_repo = UserRepository(session)
        
        # NotificationService için gerekli parçaları hazırlayalım
        from repositories.notification import NotificationRepository
        from services.notification_dispatcher import notification_dispatcher
        
        repo = NotificationRepository(session)
        self.notification_service = NotificationService(repo, notification_dispatcher)

    async def get_user_profile(self, user_id: int, current_user_id: Optional[int] = None) -> User:
        """Kullanıcının profilini getirir. current_user_id varsa takip durumunu da ekler."""
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise UserNotFoundException()
        
        if current_user_id:
            user.is_following = await self.user_repo.is_following(current_user_id, user.id)
        
        return user

    async def search_users(self, query: str, current_user_id: int, skip: int = 0, limit: int = 20):
        # Arama kutusu boş gönderilirse, sadece aktif kullanıcıları getir
        if not query or query.strip() == "":
            users = await self.user_repo.get_active_users(skip=skip, limit=limit)
        else:
            users = await self.user_repo.search_active_users(
                search_query=query, skip=skip, limit=limit
            )
        
        # Her bir kullanıcı için takip durumunu kontrol et
        for user in users:
            user.is_following = await self.user_repo.is_following(current_user_id, user.id)
            
        return users

    async def update_profile(self, current_user: User, user_in: UserUpdate) -> User:
        """
        Kullanıcı profilini günceller.
        Username veya email değişimi varsa çakışma kontrollerinden geçer.
        """
        update_data = user_in.model_dump(exclude_unset=True)

        if not update_data:
            return current_user  # Güncellenecek bir veri yoksa direkt dön

        # 1. Username çakışma kontrolü
        new_username = update_data.get("username")
        if new_username and new_username != current_user.username:
            stmt = select(self.user_repo.model).where(
                self.user_repo.model.username == new_username
            )
            existing_user = await self.session.execute(stmt)
            if existing_user.first():
                raise UsernameAlreadyExistsException()

        # 2. Email çakışma kontrolü
        new_email = update_data.get("email")
        if new_email and new_email != current_user.email:
            email_taken = await self.user_repo.email_exists(new_email)
            if email_taken:
                raise EmailAlreadyExistsException()

        # 3. Güncelleme işlemi
        updated_user = await self.user_repo.update(
            id=current_user.id, obj_data=update_data
        )
        return updated_user

    async def update_profile_image(self, user_id: int, file: UploadFile, background_tasks: BackgroundTasks):
        """
        Kullanıcı profil resmini günceller.
        Yeni resim başarıyla yüklenirse, eski resmin silinmesi arka plana atılır.
        """
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise UserNotFoundException()

        file_content = await file.read()
        old_image_url = user.profile_image_url
        
        # 1. Yeni resmi yükle (Bloklayıcı)
        new_url = await CloudinaryService.upload_image(file_content)
        
        if not new_url:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Profil resmi yüklenirken bir hata oluştu."
            )

        # 2. Veritabanını yeni URL ile güncelle
        updated_user = await self.user_repo.update(
            user_id, 
            {"profile_image_url": new_url}
        )
        
        # 3. DB güncellendiyse, eski resmi silmeyi arka plana at (Veri kaybını önler)
        if old_image_url:
            background_tasks.add_task(CloudinaryService.delete_image, old_image_url)
            
        return updated_user

    async def deactivate_account(self, current_user: User) -> dict:
        """Hesabı dondurur (Soft delete)."""
        await self.user_repo.update(id=current_user.id, obj_data={"is_active": False})
        return {"message": "Hesabınız başarıyla donduruldu."}

    # --- TAKİP SİSTEMİ İŞLEMLERİ ---

    async def follow_streamer(self, current_user: User, streamer: User) -> dict:
        """Bir yayıncıyı takip etme işlemi (Atomik ve Optimize)."""
        if current_user.id == streamer.id:
            raise NotFollowYourselfException()

        if not streamer.is_streamer:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Sadece yayıncıları (streamer) takip edebilirsiniz.",
            )

        # 1. Zaten takip ediyor mu kontrolü (Repo SELECT'ini burada yapıyoruz)
        if await self.user_repo.is_following(current_user.id, streamer.id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Bu yayıncıyı zaten takip ediyorsunuz.",
            )

        # 2. Takibi ekle (Insert)
        await self.user_repo.add_follow(current_user.id, streamer.id)
        
        # 3. Bildirim DB kaydını oluştur (Flush yapar, Commit yapmaz)
        notif_payload = NotificationCreate(
            user_id=streamer.id,
            title="Yeni Takipçi",
            body=f"{current_user.username} sana katılmaya başladı!",
            type=NotificationType.NEW_FOLLOWER,
            data={
                "follower_id": current_user.id,
                "follower_username": current_user.username,
                "follower_avatar": current_user.profile_image_url
            },
            image_url=current_user.profile_image_url
        )

        notification = await self.notification_service.create_db_record(notif_payload)

        # 4. TEK COMMIT (Unit of Work)
        # Bu aşamada hem takip hem bildirim kaydı atomik olarak DB'ye yazılır.
        await self.session.commit()

        # 5. DISPATCH (Commit başarılı olduktan sonra Worker'a gönder)
        # Race condition önlemek için commit sonrası tetiklenmesi şarttır.
        event_data = notif_payload.model_dump()
        event_data["id"] = notification.id
        await self.notification_service.dispatch_to_worker(event_data)

        await manager.send_personal_message(
            message={
                "type": "NEW_NOTIFICATION",
                "data": event_data
            },
            user_id=streamer.id
        )

        return {"message": f"'{streamer.username}' başarıyla takip edildi."}

    async def unfollow_streamer(self, follower_id: int, streamer_id: int) -> dict:
        """Bir yayıncıyı takipten çıkma işlemi."""
        if not await self.user_repo.is_following(follower_id, streamer_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Bu yayıncıyı zaten takip etmiyorsunuz.",
            )

        await self.user_repo.remove_follow(follower_id, streamer_id)
        await self.session.commit()
        return {"message": "Takipten çıkıldı."}

    async def get_follower_list_for_streamer(self, streamer_id: int, current_user_id: int) -> list[User]:
        """
        Yayıncının takipçilerini getirir.
        """
        users = await self.user_repo.get_follower_list_for_streamer(streamer_id)
        for user in users:
            user.is_following = await self.user_repo.is_following(current_user_id, user.id)
        return users

    async def get_followed_list_for_user(self, user_id: int, current_user_id: int) -> list[User]:
        """
        Kullanıcının takip ettiği yayıncıları getirir.
        """
        users = await self.user_repo.get_followed_list_for_user(user_id)
        for user in users:
            # Eğer listeyi isteyen kişi kendi listesine bakıyorsa, hepsi True'dur.
            if user_id == current_user_id:
                user.is_following = True
            else:
                user.is_following = await self.user_repo.is_following(current_user_id, user.id)
        return users

    # --- CIHAZ (DEVICE) YÖNETİMİ EKLENDİ ---
    
    async def register_user_device(self, user_id: int, payload: DeviceRegister) -> None:
        await self.user_repo.register_device(user_id, payload)
        await self.session.commit()
