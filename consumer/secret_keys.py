from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Secrets(BaseSettings):
    REGION_NAME: str = ""
    AWS_SQS_RAWVIDEOS: str = ""