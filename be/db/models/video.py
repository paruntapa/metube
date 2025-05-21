from db.base import Base 
from sqlalchemy import Column, TEXT, Integer, ForeignKey, Enum
import enum

class VideoVisibility(enum.Enum):
    PRIVATE = "PRIVATE"
    PUBLIC = "PUBLIC"
    UNLISTED = "UNLISTED"

class ProcessingStatus(enum.Enum):
    IN_PROCESSING = "IN_PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class Video(Base):
    __tablename__ = "videos"

    id = Column(Integer, primary_key=True)
    title = Column(TEXT)
    description = Column(TEXT)
    user_id = Column(TEXT, ForeignKey("users.cognito_sub"))
    video_s3_key = Column(TEXT)
    visibility = Column(Enum(VideoVisibility), nullable=False, default=VideoVisibility.PRIVATE)
    is_processing = Column(Enum(ProcessingStatus), nullable=False, default=ProcessingStatus.IN_PROCESSING)
    
