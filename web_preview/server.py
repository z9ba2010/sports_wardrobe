import os
import sys

# Ensure project root is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from backend.database import engine, Base
from backend.api.v1.wardrobe_router import router as wardrobe_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Ensure database tables exist
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(
    title="MaxFunFit - Мобильный модуль «Спортивный Гардероб» (Интерактивный стенд)",
    description="Интерактивный стенд и REST API мобильного приложения MaxFunFit",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(wardrobe_router, prefix="/api/v1")

@app.get("/", include_in_schema=False)
def serve_mobile_preview():
    index_path = os.path.join(os.path.dirname(__file__), "index.html")
    return FileResponse(index_path)

if __name__ == "__main__":
    import uvicorn
    print("\n" + "=" * 70)
    print("🚀 MaxFunFit — Мобильный интерфейс «Спортивный Гардероб» запущен!")
    print("📱 Откройте в браузере: http://127.0.0.1:8080")
    print("📖 Swagger документация: http://127.0.0.1:8080/docs")
    print("=" * 70 + "\n")
    uvicorn.run(app, host="0.0.0.0", port=8080)
