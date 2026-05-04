from contextlib import asynccontextmanager
from fastapi import FastAPI
from sqlalchemy.exc import SQLAlchemyError

from core.config import settings
from database import Base, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI lifespan context manager.
    Handles startup and shutdown of async resources (database connections).

    Startup:
        - Creates database tables
        - Initializes connection pool

    Shutdown:
        - Closes all database connections
        - Disposes engine
    """
    # Startup
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    print(f"📊 Database: {settings.DATABASE_URL}")

    try:
        # Create database tables if they don't exist
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("✅ Database tables initialized")
    except SQLAlchemyError as e:
        print(f"❌ Database initialization failed: {e}")
        raise

    yield

    # Shutdown
    print("🛑 Shutting down...")
    try:
        from services.notification_dispatcher import notification_dispatcher
        await notification_dispatcher.close()
        print("✅ Redis pool closed")
        
        await engine.dispose()
        print("✅ Database connections closed")
    except Exception as e:
        print(f"⚠️ Error during shutdown: {e}")
