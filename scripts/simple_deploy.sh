#!/bin/bash
set -e
echo "--- Starting Deployment ---"

# --- 1. GO TO APP DIRECTORY ---
cd /home/ubuntu/pro-blog-aws || exit 1
echo "Navigated to /home/ubuntu/pro-blog-aws"

# --- 2. INSTALL DEPENDENCIES ---
#    This installs awscli and jq (for reading the new file)
echo "Installing awscli and jq..."
sudo apt-get update -y
sudo apt-get install -y awscli jq

# --- 3. LOAD IMAGE URL (THE FIX) ---
#    Read the new image URI from the new artifact file
echo "Loading new image tag from imageDetail.json..."
export ECR_REPO_URL_WITH_TAG=$(jq -r .ImageURI imageDetail.json)

# --- 4. STOP OLD CONTAINERS ---
echo "Stopping old containers..."
# We pass the env var so compose can find the image name
ECR_REPO_URL_WITH_TAG=$ECR_REPO_URL_WITH_TAG docker compose down

# --- 5. GET SECRETS ---
echo "Fetching secrets from AWS..."
SECRET_KEY=$(aws secretsmanager get-secret-value --secret-id pro-blog/secret-key-v2 --query SecretString --output text --region us-east-1)
DATABASE_URL=$(aws secretsmanager get-secret-value --secret-id pro-blog/database-url-v2 --query SecretString --output text --region us-east-1)

# --- 6. CREATE .env FILE ---
echo "Creating .env.production file..."
echo "SECRET_KEY=${SECRET_KEY}" > .env.production
echo "DATABASE_URL=${DATABASE_URL}" >> .env.production

# --- 7. START NEW CONTAINERS ---
echo "Starting new containers with docker compose..."
# We pass the env var to 'up' as well
ECR_REPO_URL_WITH_TAG=$ECR_REPO_URL_WITH_TAG docker compose up -d

# --- 8. VALIDATE ---
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