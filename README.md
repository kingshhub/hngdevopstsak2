# Stage 2 - Blue/Green with Nginx Upstreams (Auto-Failover + Manual Toggle)


## Overview
This repo runs two ready-to-run Node.js images (blue & green) behind an Nginx reverse proxy. Nginx uses an upstream primary/backup setup and retries failed requests to the backup so the client receives a 200 if possible.


## Files in this repo
- `docker-compose.yml` - orchestrates `nginx`, `app_blue`, `app_green`
- `nginx/default.conf.tmpl` - Nginx config template that is rendered with `envsubst`
- `nginx/nginx-start.sh` - small startup script that renders the template and starts nginx
- `.env.example` - example environment variables
- `DECISION.md` - optional decisions and rationale
- `PART_B_REPORT.md` - research doc content for Part B


## Quick start
1. Copy `.env.example` to `.env` and set values (the grader will set these automatically in CI):


```bash
cp .env.example .env
# edit .env 
## Make sure the start script is executable:


chmod +x nginx/nginx-start.sh

## Start services:

docker compose up -d

## Verify baseline (blue active expected):

# should return 200 and header X-App-Pool: blue
curl -i http://localhost:8080/version

## Induce chaos (grader will call directly):

# simulate downtime on the blue app (the grader will do this)
curl -X POST "http://localhost:8081/chaos/start?mode=error"

## Observe Nginx failover:

# subsequent requests should be retried to green and return 200 with X-App-Pool: green
curl -i http://localhost:8080/version
## Manual toggle of active pool

# To toggle ACTIVE_POOL and reload nginx without recreating containers, update the environment variable inside the running nginx container and re-render the config:

# Example: set nginx to use green as active
docker exec nginx /bin/sh -c "export ACTIVE_POOL=green; export UPSTREAM_SERVERS='server app_green:3000 max_fails=1 fail_timeout=3s;\\n    server app_blue:3000 backup;'; envsubst < /etc/nginx/conf.d/default.conf.tmpl > /etc/nginx/conf.d/default.conf && nginx -s reload"


# Confirm
curl -i http://localhost:8080/version

## Note: CI / grader will typically set ACTIVE_POOL in the environment before starting the nginx container. If you need to switch during runtime, use the command above.


Clean up
docker compose down -v



---

# hngdevopstsak2
