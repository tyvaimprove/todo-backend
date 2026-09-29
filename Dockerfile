# --- Этап 1: Сборка зависимостей ---
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# Включаем компиляцию байткода и режим линковки для максимальной оптимизации
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Копируем только файлы конфигурации зависимостей (кэширование слоев Docker)
COPY pyproject.toml uv.lock ./

# Устанавливаем зависимости в изолированную папку проекта (без самого приложения)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev


# --- Этап 2: Финальный минимальный образ ---
FROM python:3.12-slim AS runner

WORKDIR /app

# Копируем виртуальное окружение со всеми зависимостями из этапа builder
COPY --from=builder /app/.venv /app/.venv

# Копируем исходный код приложения
COPY . .

# Добавляем путь к виртуальному окружению в PATH
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Открываем порт, на котором работает FastAPI по умолчанию в нашем коде
EXPOSE 8000

# Команда запуска приложения через виртуальное окружение
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
