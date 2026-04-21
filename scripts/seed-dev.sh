#!/bin/bash
# Seed development database with sample data
# Usage: ./seed-dev.sh

set -euo pipefail

API_URL=${1:-http://localhost:8000}

echo "Seeding development data at $API_URL..."

# Create test users
for user in alice bob charlie; do
    curl -s -X POST "$API_URL/api/users/" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$user\", \"email\": \"$user@example.com\", \"password\": \"testpass123\"}" \
        > /dev/null
    echo "Created user: $user"
done

# Create test tasks
for i in $(seq 1 5); do
    curl -s -X POST "$API_URL/api/tasks/" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Task $i\", \"description\": \"Development task $i\", \"priority\": \"medium\"}" \
        > /dev/null
    echo "Created task: Task $i"
done

echo "✅ Development data seeded!"
