#!/bin/sh
set -e # Stop script on any error

# 1. Run the database creation script
#    (We must 'cd' into the app folder first)
echo "Initializing database..."
cd /app/app
python3 create_db.py
echo "Database initialization complete."

# 2. Go back to the app root
cd /app

# 3. Start the Gunicorn web server
#    (We must tell it the app is at 'app.app:app')
echo "Starting web server..."
exec gunicorn --bind 0.0.0.0:5000 app.app:app