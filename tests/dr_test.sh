#!/bin/bash
# Otonom Medya Holdingi - Disaster Recovery Test

echo "☢️ Starting Disaster Recovery Test..."

# 1. Take Backup
./scripts/backup.sh
BACKUP_FILE=$(ls -t backups/*.tar.gz | head -n 1)

if [ -f "$BACKUP_FILE" ]; then
    echo "✅ Backup created: $BACKUP_FILE"
else
    echo "❌ Backup FAILED."
    exit 1
fi

# 2. Simulate Disaster (Delete a source from DB)
echo "💣 Simulating disaster (deleting sources)..."
docker exec medya-postgres psql -U "${POSTGRES_USER:-medya_user}" -d "${POSTGRES_DB:-medya_db}" -c "DELETE FROM sources;"

SOURCE_COUNT=$(docker exec medya-postgres psql -U "${POSTGRES_USER:-medya_user}" -d "${POSTGRES_DB:-medya_db}" -tAc "SELECT count(*) FROM sources;")
if [ "$SOURCE_COUNT" -eq "0" ]; then
    echo "✅ Disaster simulated. DB is empty."
else
    echo "❌ Simulation FAILED."
    exit 1
fi

# 3. Restore
echo "♻️ Restoring from backup..."
./scripts/restore.sh "$BACKUP_FILE"

# 4. Verify
RESTORED_COUNT=$(docker exec medya-postgres psql -U "${POSTGRES_USER:-medya_user}" -d "${POSTGRES_DB:-medya_db}" -tAc "SELECT count(*) FROM sources;")
if [ "$RESTORED_COUNT" -gt "0" ]; then
    echo "✅ Restore verified. $RESTORED_COUNT sources recovered."
else
    echo "❌ Restore verification FAILED."
    exit 1
fi

echo "🏁 Disaster recovery test successful!"
