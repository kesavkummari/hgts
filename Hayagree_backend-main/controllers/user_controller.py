from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from database import SessionLocal
from services.user_service import UserService

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/create-user/")
def create_user(user_data: dict = Body(...), db: Session = Depends(get_db)):
    user = UserService.create_user(db, user_data)
    if not user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return {"message": "Registration successful", "uid": user.uid, "email": user.email}

@router.post("/email-login-user/")
def email_login_user(email: str = Body(...), password: str = Body(...), db: Session = Depends(get_db)):
    user = UserService.email_login_user(db, email, password)
    if not user:
        raise HTTPException(status_code=400, detail="Invalid email or password")
    return {"message": "Login successfull", "email": user.email}


@router.post("/send-otp/")
def send_otp(email: str = Body(...), db: Session = Depends(get_db)):
    otp = UserService.send_otp(db, email)
    if not otp:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "OTP sent successfully"}

@router.post("/verify-otp/")
def verify_otp(email: str = Body(...), otp: str = Body(...), db: Session = Depends(get_db)):
    success, message = UserService.verify_otp(db, email, otp)
    print(f"✅ OTP Sent to {email}: {otp}")
    if not success:
        raise HTTPException(status_code=400, detail=message)
    return {"message": message}

@router.delete("/delete-user/{email}/")
def delete_user(email: str, db: Session = Depends(get_db)):
    success = UserService.delete_user(db, email)
    if not success:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": f"User with email {email} deleted successfully"}
