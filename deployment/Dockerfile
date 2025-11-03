# deployment/Dockerfile  (Python app image)
FROM python:3.12-slim AS app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends libpq-dev build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App code
COPY app/ ./app

# 👇 ADD THIS: copy your Jinja templates into the default Flask location
COPY client/templates/ ./app/templates/

# Entrypoint
COPY deployment/entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 5000
CMD ["./entrypoint.sh"]