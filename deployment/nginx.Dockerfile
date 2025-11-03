# Builds an NGINX image that includes your config + compiled static assets
# Assumes CI compiles Tailwind assets into client/static

FROM nginx:1.27-alpine

# Copy NGINX config
COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf
# Copy pre-built static assets from repo into image
# Ensure CI step creates client/static before this build.
COPY client/static /app/client/static