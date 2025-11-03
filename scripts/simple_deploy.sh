#!/bin/bash

# scripts/simple_deploy.sh
# A single script to handle the entire deployment.

# --- 1. SETTINGS ---
# Stop the script if any command fails
set -e
echo "--- Starting Deployment ---"

# --- 2. GO TO APP DIRECTORY ---
cd /home/ubuntu/pro-blog-aws || exit 1
echo "Navigated to /home/ubuntu/pro-blog-aws"

# --- 3. LOAD IMAGE URL ---
# Load the new ECR image URL from the artifact
source .env.production.codedeploy
export ECR_REPO_URL_WITH_TAG

# --- 4. STOP OLD CONTAINERS ---
# We use 'docker compose' (with a space)
echo "Stopping old containers..."
docker compose down

# --- 5. INSTALL DEPENDENCIES ---
# The server needs awscli. We'll run this every time.
echo "Installing awscli..."
sudo apt-get update -y
sudo apt-get install -y awscli

# --- 6. GET SECRETS ---
echo "Fetching secrets from AWS..."
SECRET_KEY=$(aws secretsmanager get-secret-value --secret-id pro-blog/secret-key-v2 --query SecretString --output text --region us-east-1)
DATABASE_URL=$(aws secretsmanager get-secret-value --secret-id pro-blog/database-url-v2 --query SecretString --output text --region us-east-1)

# --- 7. CREATE .env FILE ---
echo "Creating .env.production file..."
echo "SECRET_KEY=${SECRET_KEY}" > .env.production
echo "DATABASE_URL=${DATABASE_URL}" >> .env.production

# --- 8. START NEW CONTAINERS ---
echo "Starting new containers with docker compose..."
docker compose up -d

# --- 9. VALIDATE ---
echo "Waiting 10 seconds for app to start..."
sleep 10

if [ $(docker compose ps -q -f status=running blog-app) ]; then
  echo "Validation successful: blog-app is running."
  echo "--- Deployment Succeeded ---"
  exit 0
else
  echo "Validation FAILED: blog-app is not running."
  echo "---DOCKER LOGS---"
  docker compose logs blog-app
  echo "-----------------"
  echo "--- Deployment FAILED ---"
  exit 1
fi