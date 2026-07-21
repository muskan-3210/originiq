# ORACLE backend — production image (Render).
FROM python:3.11-slim AS base

# System deps: tesseract for OCR (§14.1), build tooling for a few wheels.
RUN apt-get update && apt-get install -y --no-install-recommends \
        tesseract-ocr \
        libtesseract-dev \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install Python deps first for better layer caching.
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Pull the spaCy English model used by the claim extractor.
RUN python -m spacy download en_core_web_lg

COPY . .

# Render provides $PORT at runtime.
ENV PORT=8000
EXPOSE 8000

# Health check hits the documented /health endpoint (§10.6).
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -fsS "http://localhost:${PORT}/health" || exit 1

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
