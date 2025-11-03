#!/bin/sh

# This is our entrypoint script

# 1. Run the database creation script
#    We are now "inside" the live container, which HAS the
#    environment variables from AWS Secrets Manager.
echo "Initializing database..."
python3 create_db.py
echo "Database initialization complete."

# 2. Start the Gunicorn web server
#    This is the "main" command for the container
echo "Starting web server..."
exec gunicorn --bind 0.0.0.0:5000 app:app