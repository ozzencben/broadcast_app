"""
Generic base repository for common CRUD operations.
Provides async database access patterns with SQLAlchemy 2.0.
"""

from typing import Any, Generic, Optional, Type, TypeVar

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from database import Base

T = TypeVar("T", bound=Base)


class BaseRepository(Generic[T]):
    """
    Generic repository for async CRUD operations.
    Type-safe with TypeVar for any SQLAlchemy model.
    """

    def __init__(self, session: AsyncSession, model: Type[T]) -> None:
        """
        Initialize repository with async session and model class.

        Args:
            session: AsyncSession for database operations
            model: SQLAlchemy model class
        """
        self.session = session
        self.model = model

    async def get_by_id(self, id: int) -> Optional[T]:
        """
        Retrieve single record by primary key.

        Args:
            id: Primary key value

        Returns:
            Model instance or None if not found
        """
        stmt = select(self.model).where(self.model.id == id)
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def get_all(self, skip: int = 0, limit: int = 10) -> list[T]:
        """
        Retrieve multiple records with pagination.

        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return

        Returns:
            List of model instances
        """
        stmt = select(self.model).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def create(self, obj_data: dict[str, Any]) -> T:
        """Create new record (No auto-commit)."""
        db_obj = self.model(**obj_data)
        self.session.add(db_obj)
        await self.session.flush()
        return db_obj

    async def update(self, id: int, obj_data: dict[str, Any]) -> Optional[T]:
        """Update existing record (No auto-commit)."""
        db_obj = await self.get_by_id(id)
        if not db_obj:
            return None

        for key, value in obj_data.items():
            setattr(db_obj, key, value)

        self.session.add(db_obj)
        await self.session.flush()
        return db_obj

    async def delete(self, id: int) -> bool:
        """Delete record (No auto-commit)."""
        db_obj = await self.get_by_id(id)
        if not db_obj:
            return False

        await self.session.delete(db_obj)
        await self.session.flush()
        return True
