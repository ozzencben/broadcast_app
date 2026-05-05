# Stage 1: Builder
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

# Bytecode derlemesi ve cache optimizasyonu
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_CACHE_DIR=/root/.cache/uv

WORKDIR /app

# Sadece lockfile ve pyproject.toml kopyalayarak layer cache'i koru
RUN --mount=type=cache,target=$UV_CACHE_DIR \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --frozen --no-install-project --no-dev

# Stage 2: Runtime
FROM python:3.12-slim-bookworm

WORKDIR /app

# Security: Non-root user tanımlama ve dizin hazırlığı
RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && mkdir -p /app/logs \
    && chown -R appuser:appuser /app

# Runtime için gerekli sistem bağımlılıkları
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Builder aşamasında oluşturulan .venv'i kopyala (Sahiplikle birlikte)
COPY --from=builder --chown=appuser:appuser /app/.venv /app/.venv

# Proje dosyalarını kopyala (Sahiplikle birlikte)
COPY --chown=appuser:appuser . .

# Environment setup
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Start command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]