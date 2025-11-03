#!/bin/bash

# scripts/application_start.sh

# SETTING: Stop script on any error
set -e

# 1. Install AWS CLI (the missing dependency)
echo "Installing AWS CLI..."
sudo apt-get update -y
sudo apt-get install -y awscli

# 2. Navigate to the app directory
cd /home/ubuntu/pro-blog-aws || exit 1

# 3. Stop any old containers that might be running
#    (Using correct "docker compose" command)
echo "Stopping old containers..."
docker compose down

# 4. Load the new image URL from the artifact file
source .env.production.codedeploy

# 5. Get secrets from AWS Secrets Manager
#    (This will now work because awscli is installed)
echo "Fetching secrets from AWS..."
SECRET_KEY=$(aws secretsmanager get-secret-value --secret-id pro-blog/secret-key-v2 --query SecretString --output text --region us-east-1)
DATABASE_URL=$(aws secretsmanager get-secret-value --secret-id pro-blog/database-url-v2 --query SecretString --output text --region us-east-1)

# 6. Create the real .env.production file
echo "Creating .env.production file..."
echo "SECRET_KEY=${SECRET_KEY}" > .env.production
echo "DATABASE_URL=${DATABASE_URL}" >> .env.production

# 7. Export the image URL for docker-compose to use
export ECR_REPO_URL_WITH_TAG

# 8. Start the new containers
#    (Using correct "docker compose" command)
echo "Starting new containers..."
docker compose up -d

echo "New containers started."