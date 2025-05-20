from sqlalchemy import create_engine
from secrets_keys import Secrets
from sqlalchemy.orm import sessionmaker

secrets_keys = Secrets()

engine = create_engine(
    secrets_keys.DATABASE_URL
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()

    try: 
        yield db
    finally:
        db.close()
