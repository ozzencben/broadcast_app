from schemas.notification import NotificationCreate, NotificationRead, NotificationEvent
from repositories.notification import NotificationRepository
from services.notification_dispatcher import NotificationDispatcher

class NotificationService:
    def __init__(
        self, 
        repository: NotificationRepository, 
        dispatcher: NotificationDispatcher
    ) -> None:
        self.repository = repository
        self.dispatcher = dispatcher

    async def create_db_record(self, payload: NotificationCreate) -> NotificationRead:
        """Creates record and flushes to DB. Does NOT commit (UoW managed at service/endpoint level)."""
        notification = await self.repository.create(payload.model_dump())
        return NotificationRead.model_validate(notification)

    async def dispatch_to_worker(self, event_payload: dict) -> None:
        """Enqueues the notification job to Arq/Redis."""
        event_model = NotificationEvent.model_validate(event_payload)
        await self.dispatcher.dispatch(event_model)

    async def get_history(self, user_id: int, limit: int = 20, offset: int = 0) -> list[NotificationRead]:
        """Fetches paginated notification history."""
        notifications = await self.repository.get_user_notifications(user_id, limit, offset)
        return [NotificationRead.model_validate(n) for n in notifications]