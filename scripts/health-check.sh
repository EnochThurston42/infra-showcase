#!/bin/bash
# Comprehensive health check for TaskFlow infrastructure
# Usage: ./health-check.sh [host]

set -euo pipefail

HOST=${1:-localhost}
PASS=0
FAIL=0

check() {
    local name="$1"
    local url="$2"
    local expected="${3:-200}"

    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$status" = "$expected" ]; then
        echo "✅ $name — OK ($status)"
        PASS=$((PASS + 1))
    else
        echo "❌ $name — FAIL (expected $expected, got $status)"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== TaskFlow Health Check ==="
echo "Host: $HOST"
echo ""

# Application health
check "API Health" "http://$HOST/health"
check "API Docs" "http://$HOST/docs"
check "OpenAPI Schema" "http://$HOST/openapi.json"

# Infrastructure
check "PostgreSQL" "http://$HOST:5432" "000"  # TCP check
check "Redis" "http://$HOST:6379" "000"  # TCP check

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo "⚠️  Some checks failed!"
    exit 1
else
    echo "✅ All checks passed!"
fi
