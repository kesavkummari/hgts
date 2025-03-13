from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# PostgreSQL Connection (Update with your credentials)
DATABASE_URL = "postgresql://postgres:admin123@localhost:2400/hayagree"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ✅ Test PostgreSQL Connection
try:
    with engine.connect() as connection:
        print("✅ Successfully connected to PostgreSQL!")
except Exception as e:
    print("❌ Failed to connect:", e)
