#!/bin/bash
# Otonom Medya Holdingi - Path-Independent Restore Script

if [ -z "$1" ]; then
    echo "❌ Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

BACKUP_FILE=$1
RESTORE_TMP="./restore_tmp"
mkdir -p "$RESTORE_TMP"
tar -xzf "$BACKUP_FILE" -C "$RESTORE_TMP"

echo "🔄 Restoring system..."

# 1. Database Restore
if [ -f "$RESTORE_TMP/db_dump.sql" ]; then
    echo "🗄️ Restoring Database..."
    cat "$RESTORE_TMP/db_dump.sql" | docker exec -i medya-postgres psql -U "${POSTGRES_USER:-medya_user}" -d "${POSTGRES_DB:-medya_db}"
fi

# 2. n8n Workflow Restore
if [ -f "$RESTORE_TMP/n8n_workflows.json" ]; then
    echo "🤖 Restoring n8n Workflows..."
    docker cp "$RESTORE_TMP/n8n_workflows.json" medya-n8n:/data/workflows/backup_all.json
    docker exec -i medya-n8n n8n import:workflow --input="/data/workflows/backup_all.json"
fi

rm -rf "$RESTORE_TMP"
echo "✅ Restore completed!"
