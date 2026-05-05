from services import NotificationDispatcher
from repositories import NotificationRepository
from services import NotificationService
from typing import Annotated

from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from core.config import settings  # Pydantic v2 BaseSettings
from models.user import User
from repositories.user import UserRepository
from database import get_session
from core.exceptions import UnauthorizedException

# Swagger UI'da kilidi açmak ve token'ı otomatik enjekte etmek için endpoint tanımı
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    session: Annotated[AsyncSession, Depends(get_session)],
) -> User:
    """
    JWT token'ı parse eder, sub (user_id) claim'ini çıkarır ve veritabanından kullanıcıyı çeker.
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        if payload.get("type") != "access":
            raise UnauthorizedException(message="Invalid token type.")

        user_id: str | None = payload.get("sub")
        if user_id is None:
            raise UnauthorizedException(
                message="Token payload invalid: 'sub' claim missing."
            )
    except JWTError as e:
        raise UnauthorizedException(
            message="Could not validate credentials.", details={"error": str(e)}
        )

    # Service/Repository katmanını burada tetikliyoruz (Decoupling)
    user_repo = UserRepository(session)
    user = await user_repo.get_by_id(int(user_id))

    if not user:
        raise UnauthorizedException(message="User not found.")

    if not user.is_active:
        raise UnauthorizedException(message="Inactive user account.")

    return user


async def get_current_active_streamer(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Sadece aktif yayıncıların erişimine izin verir."""
    if not current_user.is_streamer:
        raise UnauthorizedException(message="Bu işlem için yayıncı yetkisi gerekiyor.")
    return current_user


async def get_current_admin_user(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Sadece is_admin=True olan kullanıcıların geçmesine izin verir."""
    if not current_user.is_admin:
        raise UnauthorizedException(message="Bu alan sadece yöneticilere özeldir.")
    return current_user

async def get_notification_service(
    session: Annotated[AsyncSession, Depends(get_session)]
) -> NotificationService:
    from repositories.notification import NotificationRepository
    from services.notification_dispatcher import notification_dispatcher
    
    repo = NotificationRepository(session)
    return NotificationService(repo, notification_dispatcher)