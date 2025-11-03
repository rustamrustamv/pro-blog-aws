# deployment/nginx.Dockerfile
FROM nginx:1.27-alpine

# Nginx config
COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the static assets built by npm (output.css lives here)
COPY client/static /app/client/static