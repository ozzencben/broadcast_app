"""
Application configuration using Pydantic v2 BaseSettings.
"""

from pydantic_settings import BaseSettings
from pydantic import ConfigDict, field_validator, Field
from typing import List, Union


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    Pydantic v2 with ConfigDict for strict validation.
    """

    # Application settings
    APP_NAME: str = "Stream Backend API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database settings
    DATABASE_URL: str = "postgresql+asyncpg://user:password@db:5432/stream_db"
    DATABASE_ECHO: bool = False

    # JWT settings
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Server settings
    SERVER_HOST: str = "0.0.0.0"
    SERVER_PORT: int = 8000

    # Cloudinary settings
    CLOUDINARY_CLOUD_NAME: str
    CLOUDINARY_API_KEY: str
    CLOUDINARY_API_SECRET: str

    ADMIN_EMAILS: Union[str, List[str]] = []

    @field_validator("ADMIN_EMAILS", mode="before")
    @classmethod
    def parse_admin_emails(cls, v):
        # Eğer veri zaten listeyse (bazı ortamlarda öyle gelebilir) direkt dön
        if isinstance(v, list):
            return v
        # Eğer veritabanı veya env'den string gelirse (mail1,mail2)
        if isinstance(v, str) and v.strip():
            # Virgülle ayır ve her birini temizle
            return [email.strip() for email in v.split(",")]
        return []

    # Redis Settings
    REDIS_HOST: str = Field(default="localhost") # Local development için default
    REDIS_PORT: int = Field(default=6379)
    REDIS_DB: int = Field(default=0)
    
    @property
    def REDIS_URL(self) -> str:
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

    # Firebase Settings
    FIREBASE_CREDENTIALS_PATH: str = Field(default="firebase-credentials.json")

    # LiveKit Settings
    LIVEKIT_API_KEY: str
    LIVEKIT_API_SECRET: str
    LIVEKIT_URL: str

    model_config = ConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()
