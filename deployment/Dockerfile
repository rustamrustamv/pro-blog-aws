# deployment/Dockerfile

# --- 1. Base Image ---
FROM python:3.11-slim

# --- 2. Set Workdir & Install Dependencies ---
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# --- 3. Install Python Packages ---
# Copy *only* the requirements file first to cache this layer
COPY requirements.txt .
RUN pip install -r requirements.txt

# --- 4. Copy ALL Project Files ---
# Copy the app, client, deployment folders, etc.
COPY . .

# --- 5. Make Entrypoint Executable ---
RUN chmod +x /app/deployment/entrypoint.sh

# --- 6. Set the Entrypoint ---
CMD ["/app/deployment/entrypoint.sh"]