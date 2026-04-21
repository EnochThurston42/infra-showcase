#!/bin/bash
# Zero-downtime deployment script
# Usage: ./deploy.sh [version_tag]

set -euo pipefail

VERSION=${1:-latest}
COMPOSE_FILE="docker/docker-compose.prod.yml"
PROJECT_NAME="taskflow"

echo "=== Deploying TaskFlow API v${VERSION} ==="
echo "[$(date +%Y-%m-%dT%H:%M:%S)] Starting deployment..."

# Pull latest images
echo "Pulling images..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" pull

# Build new containers
echo "Building containers..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" build

# Start new containers (rolling update)
echo "Starting new containers..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d --remove-orphans --no-deps api

# Wait for health check
echo "Waiting for health check..."
sleep 10

# Verify deployment
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HEALTH_STATUS" != "200" ]; then
    echo "❌ Health check failed! Rolling back..."
    docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down
    exit 1
fi

echo "✅ Deployment successful — v${VERSION}"
echo "[$(date +%Y-%m-%dT%H:%M:%S)] Deployment complete."

# Clean up old images
docker image prune -f
