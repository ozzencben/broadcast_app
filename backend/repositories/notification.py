from typing import Sequence
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from models import Notification
from repositories.base import BaseRepository

class NotificationRepository(BaseRepository[Notification]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, Notification)

    async def get_user_notifications(
        self, user_id: int, limit: int = 20, offset: int = 0
    ) -> Sequence[Notification]:
        """
        Paginated notifications, ordered by creation date descending.
        Performance Note: Composite index on (user_id, is_read) is highly recommended.
        """
        stmt = (
            select(self.model)
            .where(self.model.user_id == user_id)
            .order_by(self.model.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def mark_all_as_read(self, user_id: int) -> None:
        """
        Bulk updates all unread notifications for a user in a single query.
        """
        stmt = (
            update(self.model)
            .where(self.model.user_id == user_id, self.model.is_read == False)
            .values(is_read=True)
        )
        await self.session.execute(stmt)