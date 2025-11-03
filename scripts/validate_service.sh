#!/bin/bash

# scripts/validate_service.sh

# This script runs to validate if the deployment was a success

# Wait for 10 seconds for the app to start
sleep 10

# Check if the 'blog-app' container is running
# (Using correct "docker compose" command)
if [ $(docker compose ps -q -f status=running blog-app) ]; then
  echo "Validation successful: blog-app is running."
  exit 0
else
  echo "Validation FAILED: blog-app is not running."
  # Check the container logs for the error
  echo "---DOCKER LOGS---"
  docker compose logs blog-app
  echo "-----------------"
  exit 1
fi