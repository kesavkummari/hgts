
from datetime import datetime, timezone, timedelta
import random
import pytz  # ✅ Ensure datetime is timezone-aware
import smtplib  # ✅ SMTP for sending emails
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from models.user_model import User
from sqlalchemy.orm import Session
from repositories.user_repository import UserRepository
from passlib.context import CryptContext
from fastapi import HTTPException

# 🔹 SMTP Email Credentials (Use your email and app password)
EMAIL_ADDRESS = "kchemalatha3@gmail.com"  # ✅ Replace with your email
EMAIL_PASSWORD = "ygzz mdbe tbdo wudx"  # ✅ Replace with your App Password

class UserService:
    @staticmethod
    def create_user(db: Session, user_data: dict):
        """Create a new user and generate an OTP"""

        if UserRepository.get_user_by_email(db, user_data["email"]):
            return None

        # ✅ Hash the password
        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        hashed_password = pwd_context.hash(user_data["password"])

        # ✅ Generate OTP and Expiry at the time of user creation
        otp = str(random.randint(100000, 999999))  # Generate 6-digit OTP
        otp_expiry = datetime.now(pytz.UTC) + timedelta(minutes=5)  # Use timezone-aware UTC datetime

        new_user = User(
            username=user_data["username"],
            email=user_data["email"],
            password=hashed_password,
            college_name=user_data["college_name"],
            year_of_graduation=user_data.get("year_of_graduation"),
            current_year=user_data.get("current_year"),
            roll_number=user_data.get("roll_number"),
            mobile_number=user_data["mobile_number"],
            alternative_mobile_number=user_data.get("alternative_mobile_number"),
            location=user_data["location"],
            gender=None if user_data["gender"] == "Select Gender" else user_data["gender"],
            otp=otp,  # ✅ Store OTP
            otp_expiry=otp_expiry,  # ✅ Store expiry time
        )

        user = UserRepository.create_user(db, new_user)

        # ✅ Send OTP via email after creating the user
        UserService.send_email_otp(user.email, otp)

        return user

    @staticmethod
    def send_email_otp(email: str, otp: str):
        """Send OTP to email using SMTP"""
        try:
            # ✅ Create email message
            subject = "Your OTP Code"
            body = f"Your OTP code is: {otp}\n\nThis code is valid for 5 minutes."
            msg = MIMEMultipart()
            msg["From"] = EMAIL_ADDRESS
            msg["To"] = email
            msg["Subject"] = subject
            msg.attach(MIMEText(body, "plain"))

            # ✅ Connect to SMTP server (Gmail)
            server = smtplib.SMTP("smtp.gmail.com", 587)
            server.starttls()  # Secure connection
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)  # Login to email
            server.sendmail(EMAIL_ADDRESS, email, msg.as_string())  # Send email
            server.quit()  # Close connection

            print(f"✅ OTP Sent to {email}: {otp}")

        except Exception as e:
            print(f"❌ Failed to send OTP: {e}")

    @staticmethod
    def send_otp(db: Session, email: str):
        """Generate and send OTP"""

        user = UserRepository.get_user_by_email(db, email)
        print(user,"userdataofsent")
        if not user:
            return None

        # ✅ Generate OTP and expiry
        otp = str(random.randint(100000, 999999))
        expiry_time = datetime.now(pytz.UTC) + timedelta(minutes=5)

        user.otp = otp
        user.otp_expiry = expiry_time

        db.commit()
        db.refresh(user)

        # ✅ Send OTP via email
        UserService.send_email_otp(user.email, otp)

        print(f"✅ OTP Sent to {email}: {otp}")

        return otp

    @staticmethod
    def verify_otp(db: Session, email: str, otp: str):
      print(f"🔍 Received Email: {email}, OTP: {otp}")

      user = UserRepository.get_user_by_email(db, email)
      print(user, "Fetched User from DB")  

      if not user:
        print("User not found")
        raise HTTPException(status_code=400, detail="User not found")

        print(f"Stored OTP: {user.otp}, Received OTP: {otp}")

    # ✅ Ensure `otp_expiry` is timezone-aware before comparing
      if user.otp_expiry.tzinfo is None:
        user.otp_expiry = user.otp_expiry.replace(tzinfo=timezone.utc)

      if user.otp != otp or datetime.now(timezone.utc) > user.otp_expiry:
        # if user.otp != otp or datetime.now() > user.otp_expiry.replace(tzinfo=None):

        print("OTP does not match or OTP Expired")
        raise HTTPException(status_code=400, detail="Invalid OTP or OTP expired")

    # ✅ OTP verification successful
      user.otp = None
      user.otp_expiry = None
      db.commit()
      db.refresh(user)

      print("✅ OTP Verified Successfully!")
      return {"message": "OTP Verified Successfully!", "success": True}
    
    @staticmethod
    @staticmethod
    def email_login_user(db: Session, email: str, password: str):
        # Call the repository method to validate the user
        user = UserRepository.check_user_password(db, email, password)
        print(user, "userlogindata1")
        if user:
            return user  # If user exists and password matches
        return None 
