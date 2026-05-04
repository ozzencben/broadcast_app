"""
User-specific repository with custom async query methods.
Extends BaseRepository for user-specific operations.
"""

from typing import Optional, List

from sqlalchemy import func, select, or_, delete, and_
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload, undefer
from models.user import User, follows
from models.user_device import UserDevice
from schemas.user_device import DeviceRegister
from repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """
    Repository for User model operations.
    Provides user-specific async queries and custom methods.
    """

    def __init__(self, session: AsyncSession) -> None:
        """
        Initialize UserRepository with AsyncSession.
        """
        super().__init__(session, User)

    async def create(self, obj_data: dict) -> User:
        """Create user (No auto-commit)."""
        db_obj = self.model(**obj_data)
        self.session.add(db_obj)
        await self.session.flush()
        return db_obj

    async def update(self, id: int, obj_data: dict) -> Optional[User]:
        """Update user (No auto-commit)."""
        user = await super().update(id, obj_data)
        return user

    async def get_by_id(self, id: int) -> Optional[User]:
        """
        Retrieve single user by primary key with followers and following preloaded.
        """
        stmt = (
            select(self.model)
            .where(self.model.id == id)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def get_all(self, skip: int = 0, limit: int = 10) -> List[User]:
        """
        Retrieve multiple users with pagination and preloaded relationships.
        """
        stmt = (
            select(self.model)
            .offset(skip)
            .limit(limit)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_by_email(self, email: str) -> Optional[User]:
        """Retrieve user by email address with preloaded relationships."""
        stmt = (
            select(User)
            .where(User.email == email)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def get_by_email_for_login(self, email: str) -> Optional[User]:
        """
        Login akışı için optimize edilmiş sorgu.
        Deferred şifreyi ve Pydantic şeması için gereken ilişkileri tek seferde çeker.
        """
        stmt = (
            select(self.model)
            .options(
                undefer(self.model.hashed_password),
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
            .where(self.model.email == email)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_active_users(self, skip: int = 0, limit: int = 10) -> List[User]:
        """Retrieve only active users with pagination and preloaded relationships."""
        stmt = (
            select(User)
            .where(User.is_active)
            .offset(skip)
            .limit(limit)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def search_active_users(
        self, search_query: str, skip: int = 0, limit: int = 20
    ) -> List[User]:
        """Kullanıcı adı, ad veya soyad içinde geçen aktif kullanıcıları arar."""
        search_term = f"%{search_query}%"

        stmt = (
            select(self.model)
            .where(
                self.model.is_active,
                or_(
                    self.model.username.ilike(search_term),
                    self.model.first_name.ilike(search_term),
                    self.model.last_name.ilike(search_term),
                ),
            )
            .offset(skip)
            .limit(limit)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )

        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def email_exists(self, email: str) -> bool:
        """Check if email already exists in database."""
        user = await self.get_by_email(email)
        return user is not None

    # --- TAKİP SİSTEMİ İŞLEMLERİ ---

    async def add_follow(self, user_id: int, streamer_id: int) -> None:
        """Kullanıcı ile yayıncı arasındaki takip ilişkisini ara tabloya ekler."""
        stmt = follows.insert().values(user_id=user_id, streamer_id=streamer_id)
        await self.session.execute(stmt)

    async def remove_follow(self, user_id: int, streamer_id: int) -> None:
        """Takip ilişkisini ara tablodan siler."""
        stmt = delete(follows).where(
            and_(follows.c.user_id == user_id, follows.c.streamer_id == streamer_id)
        )
        await self.session.execute(stmt)

    async def is_following(self, user_id: int, streamer_id: int) -> bool:
        """Kullanıcının belirli bir yayıncıyı takip edip etmediğini kontrol eder."""
        stmt = select(follows).where(
            and_(follows.c.user_id == user_id, follows.c.streamer_id == streamer_id)
        )
        result = await self.session.execute(stmt)
        return result.first() is not None

    async def get_follower_list_for_streamer(self, streamer_id: int) -> List[User]:
        """
        Yayıncının takipçilerini getirir.
        """
        stmt = (
            select(User)
            .join(follows, User.id == follows.c.user_id)
            .where(follows.c.streamer_id == streamer_id)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_followed_list_for_user(self, user_id: int) -> List[User]:
        """
        Kullanıcının takip ettiği yayıncıları getirir.
        """
        stmt = (
            select(User)
            .join(follows, User.id == follows.c.streamer_id)
            .where(follows.c.user_id == user_id)
            .options(
                selectinload(self.model.streamer_followers),
                selectinload(self.model.followed_streamers),
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    # --- FCM TOKEN İŞLEMLERİ ---

    async def register_device(self, user_id: int, schema: DeviceRegister) -> None:
        """
        Token bazlı UPSERT. Aynı token varsa bilgilerini günceller, yoksa yeni kayıt açar.
        """
        stmt = insert(UserDevice).values(
            user_id=user_id,
            fcm_token=schema.fcm_token,
            device_type=schema.device_type,
            device_model=schema.device_model
        )
        
        stmt = stmt.on_conflict_do_update(
            index_elements=['fcm_token'],
            set_={
                "user_id": user_id, 
                "device_type": schema.device_type,
                "device_model": schema.device_model,
                "last_active": func.now()
            }
        )
        await self.session.execute(stmt)

    async def get_user_fcm_tokens(self, user_id: int) -> List[str]:
        """Kullanıcının tüm FCM cihaz tokenlarını getirir."""
        stmt = select(UserDevice.fcm_token).where(UserDevice.user_id == user_id)
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def remove_user_fcm_tokens(self, tokens_to_remove: List[str]) -> None:
        """
        Geçersiz olduğu tespit edilen tokenları toplu siler.
        Note: user_id parameter removed as tokens are globally unique.
        """
        if not tokens_to_remove:
            return
        stmt = delete(UserDevice).where(UserDevice.fcm_token.in_(tokens_to_remove))
        await self.session.execute(stmt)
