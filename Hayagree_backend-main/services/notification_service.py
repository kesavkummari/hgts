from sqlalchemy.orm import Session
from models.notification_model import Notification
from repositories.notification_repository import NotificationRepository
from repositories.user_repository import UserRepository

class NotificationService:
    @staticmethod
    def send_notification(db: Session, uid: str, subject: str, message: str):
        user = UserRepository.get_user_by_email(db, uid)
        if not user:
            return None

        new_notification = Notification(
            recipient=user.email,
            subject=subject,
            message=message
        )

        return NotificationRepository.create_notification(db, new_notification)
