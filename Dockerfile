# --- Этап 1: Сборка зависимостей ---
FROM python:3.12-slim AS builder

WORKDIR /app

# Устанавливаем системные утилиты, необходимые для компиляции некоторых пакетов
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Копируем файл зависимостей
COPY requirements.txt .

# Собираем wheels (бинарные пакеты) в изолированную папку
RUN pip install --no-cache-dir --user -r requirements.txt


# --- Этап 2: Финальный минимальный образ ---
FROM python:3.12-slim AS runner

WORKDIR /app

# Копируем установленные библиотеки из предыдущего этапа (builder)
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

# Копируем исходный код приложения
COPY . .

# Добавляем путь к локальным бинарникам Python в PATH
ENV PATH=/root/.local/bin:$PATH
# Отключаем буферизацию логов Python
ENV PYTHONUNBUFFERED=1

# Открываем порт, на котором работает FastAPI по умолчанию в нашем коде
EXPOSE 8000

# Команда запуска приложения через Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
