from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Secrets(BaseSettings):
    COGNITO_CLIENT_ID: str = ""
    COGNITO_CLIENT_SECRET: str = ""
    REGION_NAME: str = ""
    DATABASE_URL: str = ""
    AWS_RAW_BUCKET_NAME: str = ""
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_THUMBNAIL_BUCKET_NAME: str = ""