# Dockerfile

# 1. Base Image: Start with an official, slim Python image
FROM python:3.11-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Install build-time dependencies (for psycopg2)
# We install these separately so they can be cached
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy the requirements file and install packages
# This is done *before* copying the rest of the app
# so Docker can cache this layer.
COPY requirements.txt .
RUN pip install -r requirements.txt

# 5. Copy the rest of your application code
COPY . .


# 6. Copy the entrypoint script and make it executable
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# 7. Set the entrypoint script as the command to run
CMD ["./entrypoint.sh"]