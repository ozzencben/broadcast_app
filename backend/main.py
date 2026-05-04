"""
FastAPI application entry point with async lifespan management.
Handles database connection pooling and application lifecycle.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.v1.endpoints.auth import auth_router
from api.v1.endpoints.user import user_router
from api.v1.endpoints.admin import admin_router
from api.v1.endpoints.notifications import router as notifications_router

from core.config import settings
from core.lifespan import lifespan
from core.logger import setup_logger
from core.handlers import setup_exception_handlers

setup_logger()


# Create FastAPI app with lifespan
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Production-ready Backend API with async/await pattern",
    lifespan=lifespan,
)

# Setup exception handlers
setup_exception_handlers(app)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme aşamasında esnek tutulabilir
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/api")
app.include_router(user_router, prefix="/api")
app.include_router(admin_router, prefix="/api")
app.include_router(notifications_router, prefix="/api/notifications", tags=["notifications"])


@app.get("/health", tags=["health"])
async def health_check() -> dict:
    """
    Health check endpoint.
    Returns application status and version.
    """
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/", tags=["root"])
async def root() -> dict:
    """Root endpoint with API information."""
    return {
        "message": "Welcome to Stream Backend API",
        "docs": "/docs",
        "health": "/health",
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host=settings.SERVER_HOST,
        port=settings.SERVER_PORT,
        reload=settings.DEBUG,
    )
