#!/bin/bash

# scripts/application_start.sh

# This script runs *after* the new files are copied.

# Navigate to the app directory
cd /home/ubuntu/pro-blog-aws || exit 1

# 1. Load the new image URL from the artifact file
source .env.production.codedeploy

# 2. Get secrets from AWS Secrets Manager
#    The EC2 instance has an IAM Role that lets it do this
SECRET_KEY=$(aws secretsmanager get-secret-value --secret-id pro-blog/secret-key-v2 --query SecretString --output text --region us-east-1)
DATABASE_URL=$(aws secretsmanager get-secret-value --secret-id pro-blog/database-url-v2 --query SecretString --output text --region us-east-1)

# 3. Create the real .env.production file for docker-compose
echo "SECRET_KEY=${SECRET_KEY}" > .env.production
echo "DATABASE_URL=${DATABASE_URL}" >> .env.production

# 4. Export the image URL for docker-compose
export ECR_REPO_URL_WITH_TAG

# 5. Start the new containers
docker-compose up -d

echo "New containers started."