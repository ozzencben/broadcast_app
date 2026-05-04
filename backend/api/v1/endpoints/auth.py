"""
Authentication API endpoints for user registration and login.
Includes error handling and HTTP exception responses.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_session
from schemas.user import UserCreate, UserLogin, TokenResponse
from services.auth import AuthService

auth_router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)


@auth_router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
async def register(
    user_data: UserCreate,
    session: AsyncSession = Depends(get_session),
) -> TokenResponse:
    """
    Register new user account.

    Args:
        user_data: UserCreate schema with email and password
        session: Async database session (injected)

    Returns:
        TokenResponse with access token and user data

    Raises:
        HTTPException 400: Email already registered
        HTTPException 500: Internal server error
    """
    try:
        auth_service = AuthService(session)
        token_response = await auth_service.register_user(user_data)
        return token_response

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error",
        )


@auth_router.post("/login", response_model=TokenResponse)
async def login(
    user_data: UserLogin,
    session: AsyncSession = Depends(get_session),
) -> TokenResponse:
    """
    Authenticate user and return access token.

    Args:
        user_data: UserLogin schema with email and password
        session: Async database session (injected)

    Returns:
        TokenResponse with access token and user data

    Raises:
        HTTPException 401: Invalid credentials
        HTTPException 500: Internal server error
    """
    try:
        auth_service = AuthService(session)
        token_response = await auth_service.login_user(
            user_data.email, user_data.password
        )
        return token_response

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error",
        )


@auth_router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    # embed=True yaparak JSON içinde {"refresh_token": "..."} şeklinde bekliyoruz
    refresh_token: str = Body(..., embed=True),
    session: AsyncSession = Depends(get_session),
) -> TokenResponse:
    try:
        auth_service = AuthService(session)
        token_response = await auth_service.refresh_access_token(refresh_token)
        return token_response

    except ValueError as e:
        # ValueError'ları burada yakalayıp 401'e çevirmen çok doğru bir yaklaşım
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        # Beklenmedik hatalar için loglama eklemek iyi olabilir
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Oturum tazelenirken beklenmedik bir hata oluştu.",
        )
