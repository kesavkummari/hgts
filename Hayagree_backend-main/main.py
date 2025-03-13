from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from database import engine, Base
from controllers import user_controller, notification_controller
import asyncio


# Initialize FastAPI
app = FastAPI()

# Add CORS middleware (public access from all origins)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for public access
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers 
)

# Sample API endpoint to display a message
@app.get("/message")
def get_message():
    return {"message": "Hello"}


# Include Routers
app.include_router(user_controller.router)
app.include_router(notification_controller.router)

PORT = 7000  # Change this value to modify the port

# Run FastAPI with the specified port
if __name__ == "__main__":
    # Create tables
    Base.metadata.create_all(bind=engine)
    uvicorn.run("main:app", host="0.0.0.0", port=PORT, reload=True)
