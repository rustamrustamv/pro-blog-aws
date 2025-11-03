#!/bin/bash

# scripts/before_install.sh

# This script runs *before* the new application files are copied over.

# Navigate to the app directory
cd /home/ubuntu/pro-blog-aws || exit 1

# Stop and remove the old containers (if they exist)
# This allows the new version to start
docker-compose down

echo "Old containers stopped."