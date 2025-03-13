from sqlalchemy import Column, Integer, String, Text, TIMESTAMP, func
from database import Base

class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = {"schema": "notifications"}

    id = Column(Integer, primary_key=True, index=True)
    recipient = Column(String, index=True, nullable=False)
    subject = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
