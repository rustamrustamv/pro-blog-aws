# deployment/nginx.Dockerfile
FROM nginx:1.27-alpine

# Use our nginx.conf
COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the prebuilt static assets produced in CI (e.g., styles.css)
COPY client/static /app/client/static