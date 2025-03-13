from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from services.notification_service import NotificationService

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/send-notification/{uid}/")
def send_notification(uid: str, subject: str, message: str, db: Session = Depends(get_db)):
    notification = NotificationService.send_notification(db, uid, subject, message)
    if not notification:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": f"Notification sent to {notification.recipient}"}
