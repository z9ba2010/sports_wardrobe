import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from backend.database import engine, Base
from backend.api.v1.wardrobe_router import router as wardrobe_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Создание таблиц БД при старте
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(
    title="MaxFunFit - Модуль «Спортивный Гардероб»",
    description="REST API для управления персональным гардеробом и интеграции с бэкендом «Парсер»",
    version="1.0.0",
    lifespan=lifespan
)

# CORS для мобильного приложения и веб-превью
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(wardrobe_router, prefix="/api/v1")

@app.get("/health", tags=["Status"])
def health():
    return {"status": "ok", "module": "Wardrobe"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8001, reload=True)
