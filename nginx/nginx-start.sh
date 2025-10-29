#!/bin/sh
set -e

# Render Nginx template with env vars
envsubst < /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf

# Validate the generated config
nginx -t

# Run Nginx in foreground
exec nginx -g 'daemon off;'
