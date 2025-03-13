import uuid
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime
from database import Base

class User(Base):
    __tablename__ = "users"
    __table_args__ = {"schema": "notifications"}

    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String, unique=True, index=True, default=lambda: str(uuid.uuid4()))
    username = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    college_name = Column(String, nullable=False)
    year_of_graduation = Column(Integer, nullable=True)
    current_year = Column(Integer, nullable=True)
    roll_number = Column(String, nullable=True)
    mobile_number = Column(String, nullable=False)
    alternative_mobile_number = Column(String, nullable=True)
    location = Column(String, nullable=False)
    gender = Column(String, nullable=False)

    # Added OTP fields
    otp = Column(String, nullable=True)  
    otp_expiry = Column(DateTime, nullable=True, default=lambda: datetime.now(timezone.utc))
