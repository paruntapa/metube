from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from db.db import get_db
from db.middleware.auth_middleware import get_current_user
from db.models.video import ProcessingStatus, VideoVisibility, Video
from sqlalchemy import or_
from db.redis_db import redis_client
import json

router = APIRouter()

@router.get("/all")
async def get_all_videos(db: Session = Depends(get_db), user=Depends(get_current_user)):
    all_videos = db.query(Video).filter(Video.is_processing == ProcessingStatus.COMPLETED, Video.visibility == VideoVisibility.PUBLIC).all()
    return all_videos

@router.get("/")
async def get_videos_info(video_id:str, db: Session = Depends(get_db), user=Depends(get_current_user)):

    cached_key = f"video:{video_id}"
    cached_data = redis_client.get(cached_key)

    if cached_data:
        print(cached_data)
        return json.loads(cached_data)
    video = (
        db.query(Video).filter(
        Video.id == video_id,
        Video.is_processing == ProcessingStatus.COMPLETED, 
        or_(
            Video.visibility == VideoVisibility.PUBLIC,
            Video.visibility == VideoVisibility.UNLISTED
        )
        ).first()
    )

    print(video.to_dict())

    redis_client.setex(cached_key, 3600, json.dumps(video.to_dict()))
    
    return video.to_dict()

@router.post("/")
def update_video_by_id(id: str, db: Session = Depends(get_db)):
    video = db.query(Video).filter(Video.id == id).first()

    if not video:
        raise HTTPException(status_code=404, detail="Video not found")
    
    video.is_processing = ProcessingStatus.COMPLETED
    db.commit()
    db.refresh(video)

    return video

