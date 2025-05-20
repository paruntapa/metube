from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import auth
from db.base import Base
from db.db import engine
app = FastAPI()

origins = ["https://localhost", "http://localhost:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(auth.router, prefix="/auth")

@app.get('/')
def slash():
   return "namaste!!!"

Base.metadata.create_all(engine)