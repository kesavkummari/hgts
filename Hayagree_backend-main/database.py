from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# PostgreSQL Connection (Update with your credentials)
# DATABASE_URL = "postgresql://postgres:admin123@localhost:2400/hayagree"
DATABASE_URL = "postgresql://postgres:asdf%401234@localhost:5432/postgres"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ✅ Test PostgreSQL Connection
try:
    with engine.connect() as connection:
        print("✅ Successfully connected to PostgreSQL!")
except Exception as e:
    print("❌ Failed to connect:", e)
