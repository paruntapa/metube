FROM python:3.10-slim

RUN apt-get update && apt-get install -y ffmpeg && apt-get clean && rm -rf var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "main.py"]