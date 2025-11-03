# deployment/Dockerfile

# --- STAGE 1: Build the CSS Frontend ---
# Use an official Node.js image
FROM node:20-slim as frontend-builder

WORKDIR /frontend

# Copy all the Tailwind/NPM config files
COPY package.json .
COPY package-lock.json .
COPY client/tailwind.config.js .
COPY client/input.css ./client/input.css

# Copy the templates to be scanned by Tailwind
COPY client/templates/ ./client/templates

# Install dependencies and build the final output.css file
RUN npm install
RUN npm run build:css


# --- STAGE 2: Build the Python Backend ---
# Start from our Python image
FROM python:3.11-slim

WORKDIR /app

# Install build-time dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy our application code
COPY app/ ./app

# Copy the deployment scripts and configs
COPY deployment/entrypoint.sh .
COPY deployment/nginx.conf .
COPY deployment/docker-compose.yml .

# --- THIS IS THE MAGIC ---
# Copy the *final CSS file* from the 'frontend-builder' stage
COPY --from=frontend-builder /frontend/client/static/output.css ./client/static/output.css

# Copy the rest of the client files (HTML templates)
COPY client/templates/ ./client/templates

# Make Entrypoint Executable
RUN chmod +x ./entrypoint.sh

# Set the Entrypoint
CMD ["./entrypoint.sh"]