#!/bin/bash

# scripts/application_start.sh

# Navigate to the app directory
cd /home/ubuntu/pro-blog-aws || exit 1

# 1. Stop any old containers that might be running
echo "Stopping old containers..."
docker-compose down

# 2. Load the new image URL from the artifact file
source .env.production.codedeploy

# 3. Get secrets from AWS Secrets Manager
echo "Fetching secrets from AWS..."
SECRET_KEY=$(aws secretsmanager get-secret-value --secret-id pro-blog/secret-key-v2 --query SecretString --output text --region us-east-1)
DATABASE_URL=$(aws secretsmanager get-secret-value --secret-id pro-blog/database-url-v2 --query SecretString --output text --region us-east-1)

# 4. Create the real .env.production file for docker-compose
echo "Creating .env.production file..."
echo "SECRET_KEY=${SECRET_KEY}" > .env.production
echo "DATABASE_URL=${DATABASE_URL}" >> .env.production

# 5. Export the image URL for docker-compose to use
export ECR_REPO_URL_WITH_TAG

# 6. Start the new containers
echo "Starting new containers..."
docker-compose up -d

echo "New containers started."