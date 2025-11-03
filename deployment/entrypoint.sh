#!/bin/sh
set -e # Stop script on any error

# We are in the WORKDIR /app

# 1. Add the current directory to the Python path
#    This lets Python find the 'app' package.
export PYTHONPATH=$PYTHONPATH:/app

# 2. Run the database creation script *as a module*
echo "Initializing database..."
python3 -m app.create_db
echo "Database initialization complete."

# 3. Start the Gunicorn web server *as a module*
echo "Starting web server..."
exec gunicorn --bind 0.0.0.0:5000 app.app:app