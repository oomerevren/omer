#!/bin/bash
# Otonom Medya Holdingi - Path-Independent Backup Script

# Proje kök dizinini belirle
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# .env dosyasından değişkenleri yükle
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

BACKUP_DIR="./backups/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🚀 Starting backup for $PROJECT_ROOT..."

# 1. PostgreSQL Backup (Using .env variables)
echo "🗄️ Dumping Database..."
docker exec medya-postgres pg_dump -U "${POSTGRES_USER:-medya_user}" "${POSTGRES_DB:-medya_db}" > "$BACKUP_DIR/db_dump.sql"

# 2. n8n Workflow Export
echo "🤖 Exporting n8n Workflows..."
docker exec medya-n8n n8n export:workflow --all --output="/data/workflows/backup_all.json"
# n8n container volumes mapping must be correct
docker cp medya-n8n:/data/workflows/backup_all.json "$BACKUP_DIR/n8n_workflows.json"

# 3. Config & Env Backup
echo "⚙️ Backing up config files..."
cp .env "$BACKUP_DIR/.env.bak"
cp -r config/ "$BACKUP_DIR/config/"

# 4. Compression
tar -czf "$BACKUP_DIR.tar.gz" -C "$BACKUP_DIR" .
rm -rf "$BACKUP_DIR"

echo "✅ Backup completed: $BACKUP_DIR.tar.gz"
