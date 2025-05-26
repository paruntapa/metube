from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Secrets(BaseSettings):
    REGION_NAME: str = ""
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    S3_BUCKET: str = ""
    S3_KEY: str = ""
    S3_PROCESSED_VIDEOS_BUCKET: str = ""
    BACKEND_URL: str = ""

