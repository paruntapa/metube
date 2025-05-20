from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Secrets(BaseSettings):
    COGNITO_CLIENT_ID: str = ""
    COGNITO_CLIENT_SECRET: str = ""
    REGION_NAME: str = ""
    DATABASE_URL: str = ""