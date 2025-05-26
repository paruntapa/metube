from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import auth, upload, video
from db.base import Base
from db.db import engine
app = FastAPI()

origins = ["*"]  # Allow all origins for development - change this in production

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(auth.router, prefix="/auth")
app.include_router(upload.router, prefix="/upload/video")
app.include_router(video.router, prefix="/videos")

@app.get('/')
def slash():
   return "namaste!!!"

Base.metadata.create_all(engine)