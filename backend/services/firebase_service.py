import firebase_admin
from firebase_admin import credentials, messaging
from anyio import to_thread
from core.config import settings
from schemas.notification import NotificationEvent
from typing import List

class FirebaseService:
    def __init__(self) -> None:
        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred)

    async def send_multicast(self, event: NotificationEvent, tokens: List[str]) -> messaging.BatchResponse:
        """
        Multicast gönderimi. Admin SDK senkron olduğu için thread-pool üzerinde koşturulur.
        """
        # FCM sadece string veri kabul eder
        string_payload = {k: str(v) for k, v in event.data.items()}
        
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=event.title,
                body=event.body,
                image=event.image_url
            ),
            data=string_payload,
            tokens=tokens,
        )

        return await to_thread.run_sync(messaging.send_each_for_multicast, message)

firebase_service = FirebaseService()