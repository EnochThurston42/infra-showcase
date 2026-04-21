#!/bin/bash
set -e

echo "[$(date +%Y-%m-%dT%H:%M:%S)] Starting TaskFlow API..."

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
until curl -s http://db:5432 > /dev/null 2>&1 || pg_isready -h db -p 5432 -U taskflow > /dev/null 2>&1; do
    sleep 1
done
echo "PostgreSQL is ready."

# Wait for Redis
echo "Waiting for Redis..."
until redis-cli -h redis ping > /dev/null 2>&1; do
    sleep 1
done
echo "Redis is ready."

# Run database migrations (if alembic is available)
if command -v alembic &> /dev/null; then
    echo "Running database migrations..."
    alembic upgrade head
fi

# Execute the main command
exec "$@"
