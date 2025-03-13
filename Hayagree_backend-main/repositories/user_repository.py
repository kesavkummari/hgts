import random
import string
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from models.user_model import User
import pytz
from bcrypt import checkpw

class UserRepository:
    @staticmethod
    def create_user(db: Session, user: User):
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def get_user_by_email(db: Session, email: str):
        return db.query(User).filter(User.email == email).first()

    @staticmethod
    def delete_user(db: Session, email: str):
        user = db.query(User).filter(User.email == email).first()
        if user:
            db.delete(user)
            db.commit()
            return True
        return False

    @staticmethod
    def store_otp(db: Session, email: str):
        """Generate and store a random OTP"""
        user = db.query(User).filter(User.email == email).first()
        if not user:
            return None

        otp = ''.join(random.choices(string.digits, k=6))  # Generate 6-digit OTP
        otp_expiry = datetime.utcnow() + timedelta(minutes=5)  # OTP expires in 5 min

        user.otp = otp
        user.otp_expiry = otp_expiry
        db.commit()

        return otp  # Return OTP for sending via email/SMS

    @staticmethod
    def verify_otp(db: Session, email: str, otp: str):
        """Check if OTP is valid and not expired"""
        user = db.query(User).filter(User.email == email).first()
        print(user,"user")
        if not user or not user.otp:
            return False, "Invalid OTP."

        if user.otp != otp:
            return False, "Incorrect OTP."
        if datetime.now(pytz.UTC) > user.otp_expiry:
            return False, "OTP has expired. Please request a new one."

        # Clear OTP after successful verification
        user.otp = None
        user.otp_expiry = None
        db.commit()

        return True, "OTP Verified Successfully!"
    
    @staticmethod
    def check_user_password(db: Session, email: str, password: str):
        """Verify if the user's password matches the stored password"""
        user = db.query(User).filter(User.email == email).first()
        print(user, "userlogindata")  # Debug log for checking user data
        if user:
            # Hash the incoming password and compare it to the stored hash
            if checkpw(password.encode('utf-8'), user.password.encode('utf-8')):
                return user
        return None
    