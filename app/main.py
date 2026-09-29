from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth
import time

app = FastAPI(
    title="To-Do List API",
    description="Бэкенд для приложения To-Do на FastAPI",
    version="1.0.0"
)

# Настройка CORS (разрешаем фронтенду подключаться к бэкенду)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В будущем здесь можно указать конкретный адрес фронтенда (например, http://localhost:3000)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Время запуска приложения для подсчета uptime
START_TIME = time.time()



api_router = APIRouter()
api_router.include_router(auth.router)



@app.get("/health", tags=["System"])
def health_check():
    """
    Эндпоинт для проверки здоровья (Healthcheck).
    Используется системами мониторинга и Docker для проверки статуса приложения.
    """
    uptime = time.time() - START_TIME
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "uptime_seconds": round(uptime, 2),
        "version": app.version
    }

@app.get("/", tags=["Root"])
def read_root():
    """Приветственное сообщение корневого эндпоинта"""
    return {"message": "Добро пожаловать в To-Do API! Перейдите на /docs для просмотра документации."}


@app.get("/test", tags=["Root"])
def read_root():
    """Приветственное сообщение корневого эндпоинта"""
    return {"message": "Успешный тест."}
