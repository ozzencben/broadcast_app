from enum import Enum
from datetime import date
from typing import Optional
from sqlalchemy import (
    String,
    Boolean,
    Date,
    Text,
    Enum as SAEnum,
    Table,
    Column,
    Integer,
    ForeignKey,
    DateTime,
    func,
    Index,
    JSON,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship, deferred

from models.base_model import AbstractBase


follows = Table(
    "follows",
    AbstractBase.metadata,
    Column(
        "user_id", Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    ),
    Column(
        "streamer_id",
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column("created_at", DateTime, server_default=func.now()),
    Index("idx_follows_streamer", "streamer_id"),  # Yayıncı bazlı aramalarda hız için
)


class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"
    PREFER_NOT_TO_SAY = "prefer_not_to_say"


class User(AbstractBase):
    """
    User table model for Stream App.
    Inherits id, created_at, and updated_at from AbstractBase.
    """

    # Kimlik Bilgileri
    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    hashed_password: Mapped[str] = deferred(mapped_column(String(255), nullable=False))
    username: Mapped[str] = mapped_column(
        String(50), unique=True, index=True, nullable=False
    )

    # Profil Bilgileri
    first_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    last_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    gender: Mapped[Gender] = mapped_column(
        SAEnum(Gender), default=Gender.PREFER_NOT_TO_SAY, nullable=False
    )
    birth_date: Mapped[Optional[date]] = mapped_column(
        Date, nullable=True
    )  # Yaş yerine doğum tarihi tutmak her zaman daha profesyoneldir
    bio: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    profile_image_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)

    # Yetkilendirme ve Roller
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_streamer: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    is_verified_streamer: Mapped[bool] = mapped_column(
        Boolean, default=False, nullable=False
    )

    # --- TAKİP İLİŞKİLERİ GÜNCELLENDİ ---

    # Bir kullanıcının takip ettiği yayıncılar listesi
    followed_streamers: Mapped[list["User"]] = relationship(
        "User",
        secondary=follows,
        primaryjoin="User.id == follows.c.user_id",
        secondaryjoin="User.id == follows.c.streamer_id",
        back_populates="streamer_followers",
        overlaps="streamer_followers",
    )

    # Bir yayıncıyı takip eden kullanıcılar listesi
    streamer_followers: Mapped[list["User"]] = relationship(
        "User",
        secondary=follows,
        primaryjoin="User.id == follows.c.streamer_id",
        secondaryjoin="User.id == follows.c.user_id",
        back_populates="followed_streamers",
        overlaps="followed_streamers",
    )

    @property
    def followers_count(self) -> int:
        # Eğer ilişki yüklenmişse sayısını döndür, yoksa 0
        return len(self.streamer_followers) if self.streamer_followers else 0

    @property
    def following_count(self) -> int:
        return len(self.followed_streamers) if self.followed_streamers else 0

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # DB'ye yazılmayan, sadece response için kullanılan geçici alan.
        # Servis katmanında manuel olarak set edilir.
        self.is_following: bool = False

    def __repr__(self) -> str:
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}', is_streamer={self.is_streamer})>"
