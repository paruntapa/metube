from pydantic import BaseModel

class UploadMetadata(BaseModel):
    video_id: str
    title: str
    video_s3_key: str
    visibility: str
    description: str