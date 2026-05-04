"""
Authentication service with password hashing and JWT token generation.
Contains core business logic for user authentication.
"""

from sqlalchemy import select
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from repositories.user import UserRepository
from schemas.user import UserCreate, UserRead, TokenResponse
from utils.jwt import create_access_token, create_refresh_token, decode_token
from core.config import settings
from jose import JWTError

# Password hashing context with bcrypt
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


class AuthService:
    """
    Authentication service for user registration, login, and token management.
    Handles password hashing and JWT token generation.
    """

    def __init__(self, session: AsyncSession) -> None:
        """
        Initialize AuthService with database session.

        Args:
            session: AsyncSession for database operations
        """
        self.session = session
        self.user_repo = UserRepository(session)

    async def register_user(self, user_data: UserCreate) -> TokenResponse:
        """
        Kullanıcıyı sadece email ve password ile kaydeder.
        Username email'den otomatik türetilir.
        """
        # 1. Email kontrolü
        if await self.user_repo.email_exists(user_data.email):
            raise ValueError(f"Email {user_data.email} already registered")

        # 2. Email'den username türetme (ozencben@gmail.com -> ozencben)
        base_username = user_data.email.split("@")[0]
        username = base_username

        is_admin = user_data.email in settings.ADMIN_EMAILS

        # 3. Username çakışma kontrolü ve otomatik benzersiz yapma
        # Eğer bu username alınmışsa, sonuna uuid'den kısa bir parça ekleyelim
        stmt = select(self.user_repo.model).where(
            self.user_repo.model.username == username
        )
        result = await self.session.execute(stmt)
        if result.scalars().first():
            # Çakışma varsa: ozencben -> ozencben_a1b2
            suffix = str(uuid.uuid4())[:4]
            username = f"{base_username}_{suffix}"

        # 4. Şifreyi hashle
        hashed_password = self.hash_password(user_data.password)

        # 5. Kullanıcıyı oluştur (first_name ve last_name başlangıçta None)
        user_dict = {
            "email": user_data.email,
            "username": username,
            "hashed_password": hashed_password,
            "first_name": None,
            "last_name": None,
            "is_active": True,
            "is_admin": is_admin,
            "is_streamer": False,
            "is_verified_streamer": False,
        }

        user = await self.user_repo.create(user_dict)

        #  generation JWT... (aynı kalıyor)
        access_token = create_access_token(
            data={"sub": str(user.id), "email": user.email}
        )
        refresh_token = create_refresh_token(
            data={"sub": str(user.id), "email": user.email}
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user=UserRead.model_validate(user),
        )

    async def login_user(self, email: str, password: str) -> TokenResponse:
        """
        Authenticate user and return access token.

        Args:
            email: User email address
            password: User password (plaintext)

        Returns:
            TokenResponse with JWT access token and user data

        Raises:
            ValueError: If credentials are invalid
        """
        # Find user by email
        user = await self.user_repo.get_by_email_for_login(email)
        if not user:
            print(f"DEBUG: User not found for email: {email}")
            raise ValueError("Invalid email or password")

        # Verify password
        is_valid = self.verify_password(password, user.hashed_password)
        if not is_valid:
            print(f"DEBUG: Password mismatch for user: {email}")
            raise ValueError("Invalid email or password")

        # Check if user is active
        if not user.is_active:
            print(f"DEBUG: Inactive user account: {email}")
            raise ValueError("User account is inactive")

        # Generate JWT token
        access_token = create_access_token(
            data={"sub": str(user.id), "email": user.email}
        )

        refresh_token = create_refresh_token(
            data={"sub": str(user.id), "email": user.email}
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user=UserRead.model_validate(user),
        )

    async def refresh_access_token(self, refresh_token: str) -> TokenResponse:
        """
        Refresh access token using a valid refresh token.

        Args:
            refresh_token: JWT refresh token

        Returns:
            TokenResponse with new access token

        Raises:
            ValueError: If refresh token is invalid or expired
        """
        try:
            payload = decode_token(refresh_token)
            if payload.get("type") != "refresh":
                raise ValueError("Invalid token type")
            user_id = payload.get("sub")
            if user_id is None:
                raise ValueError("Invalid token payload")
        except JWTError as e:
            raise ValueError(f"Could not validate refresh token: {str(e)}")

        user = await self.user_repo.get_by_id(int(user_id))
        if not user or not user.is_active:
            raise ValueError("User not found or inactive")

        # Generate new access token
        access_token = create_access_token(
            data={"sub": str(user.id), "email": user.email}
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,  # Refresh token aynı kalır
            token_type="bearer",
            user=UserRead.model_validate(user),
        )

    @staticmethod
    def hash_password(password: str) -> str:
        """
        Hash password using bcrypt.

        Args:
            password: Plaintext password

        Returns:
            Hashed password string
        """
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """
        Verify plaintext password against hashed password.

        Args:
            plain_password: Plaintext password from user input
            hashed_password: Stored hashed password

        Returns:
            True if password matches, False otherwise
        """
        return pwd_context.verify(plain_password, hashed_password)
