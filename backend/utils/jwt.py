import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from jose import JWTError, jwt

from core.config import settings


def _create_token(
    token_type: str,
    data: Dict[str, Any],
    expire: datetime,
) -> str:
    """Internal base logic for token generation."""
    to_encode = data.copy()
    to_encode.update(
        {
            "exp": expire,
            "type": token_type,
            "jti": str(
                uuid.uuid4()
            ),  # Benzersiz token ID'si (Revocation/Blacklist için şart)
        }
    )

    return jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )


def create_access_token(
    data: Dict[str, Any],
    expires_delta: Optional[timedelta] = None,
) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    return _create_token(token_type="access", data=data, expire=expire)


def create_refresh_token(
    data: Dict[str, Any],
    expires_delta: Optional[timedelta] = None,
) -> str:
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    )
    return _create_token(token_type="refresh", data=data, expire=expire)


def decode_token(token: str) -> Optional[Dict[str, Any]]:
    try:
        return jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
    except JWTError:
        return None
