"""
Pydantic v2 schemas for user-related requests and responses.
"""

from datetime import datetime, date
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field
from models.user import Gender


class UserBase(BaseModel):
    """Base user schema with common fields."""

    email: EmailStr = Field(..., description="User email address")

    model_config = ConfigDict(from_attributes=True)


class UserCreate(UserBase):
    """
    Schema for user registration.
    Kullanıcıyı yormamak için sadece email ve şifre alıyoruz.
    """

    password: str = Field(..., min_length=8, description="User password")


class UserUpdate(BaseModel):
    """Schema for updating user data. All fields are optional."""

    email: Optional[EmailStr] = None
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    gender: Optional[Gender] = None
    birth_date: Optional[date] = None
    bio: Optional[str] = None
    profile_image_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class UserLogin(BaseModel):
    """Schema for user login."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")

    model_config = ConfigDict(from_attributes=True)


class UserRead(UserBase):
    """
    Schema for reading user data with all profile details.
    Önemli: Yeni kayıt olan kullanıcıda bazı alanlar null olacağı için 'Optional' ve default 'None' yapıldı.
    """

    id: int
    username: str

    # Yeni kayıt olanlarda bu alanlar None döneceği için hata vermemesi sağlandı
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    gender: Gender
    birth_date: Optional[date] = None
    bio: Optional[str] = None
    profile_image_url: Optional[str] = None

    # Yetki ve Durum
    is_active: bool
    is_admin: bool
    is_streamer: bool
    is_verified_streamer: bool

    # Eğer bu kişi bir yayıncıysa, onu kaç kişi takip ediyor?
    followers_count: int = Field(0, description="Number of users following this streamer")
    
    # Eğer bu kişi bir kullanıcıysa, kaç yayıncıyı takip ediyor?
    following_count: int = Field(0, description="Number of streamers followed by this user")
    
    # İstek atan kullanıcı (ben), bu profili takip ediyor muyum?
    # Not: Kendi profilimize bakarken veya giriş yapmamışken None/False dönebilir.
    is_following: bool = Field(False, description="True if the current user follows this profile")

    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TokenResponse(BaseModel):
    """Schema for authentication token response."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserRead
