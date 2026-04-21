#!/bin/bash
# PostgreSQL backup script
# Usage: ./backup-db.sh [output_dir]

set -euo pipefail

OUTPUT_DIR=${1:-./backups}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${OUTPUT_DIR}/taskflow_${TIMESTAMP}.sql.gz"

mkdir -p "$OUTPUT_DIR"

echo "Backing up TaskFlow database..."
docker compose -f docker/docker-compose.prod.yml exec -T db \
    pg_dump -U taskflow taskflow | gzip > "$BACKUP_FILE"

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "✅ Backup complete: $BACKUP_FILE ($SIZE)"

# Clean up backups older than 7 days
find "$OUTPUT_DIR" -name "taskflow_*.sql.gz" -mtime +7 -delete
echo "Cleaned up backups older than 7 days"
