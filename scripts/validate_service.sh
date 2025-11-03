#!/bin/bash

# scripts/validate_service.sh

# This script runs to validate if the deployment was a success

# Wait for 5 seconds for the app to start
sleep 5

# Check if the 'blog-app' container is running
if [ $(docker ps -q -f name=blog-app -f status=running) ]; then
  echo "Validation successful: blog-app is running."
  exit 0
else
  echo "Validation FAILED: blog-app is not running."
  exit 1
fi