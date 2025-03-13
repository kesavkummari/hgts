from sqlalchemy.orm import Session
from models.notification_model import Notification

class NotificationRepository:
    @staticmethod
    def create_notification(db: Session, notification: Notification):
        db.add(notification)
        db.commit()
        return notification
