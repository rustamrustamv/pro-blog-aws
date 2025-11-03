# deployment/Dockerfile
FROM python:3.12-slim AS app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# OS deps (include libpq-dev only if you use psycopg2/PG)
RUN apt-get update \
 && apt-get install -y --no-install-recommends libpq-dev build-essential \
 && rm -rf /var/lib/apt/lists/*

# Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App code & entrypoint
COPY app/ ./app
COPY deployment/entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 5000
CMD ["./entrypoint.sh"]