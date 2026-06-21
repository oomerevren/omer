#!/bin/bash
# Otonom Medya Holdingi - REAL E2E FLOW TEST
# This script simulates the actual flow from DB to Render to Publish with detailed logging

LOG_FILE="/storage/logs/e2e_test.log"
echo "--- E2E TEST START: $(date) ---" > $LOG_FILE

# 1. DATABASE CHECK & INGEST
echo "[1/4] Checking DB and Ingesting Test News..." | tee -a $LOG_FILE
docker exec medya-postgres psql -U medya_user -d medya_db -c "INSERT INTO editorial_hub (domain_tag, content_payload, swarm_status) VALUES ('test', '{\"text\": \"E2E Test Content\", \"title\": \"Test Title\"}', 'APPROVED') RETURNING post_id;" >> $LOG_FILE 2>&1

# 2. VIDEO RENDER TEST
echo "[2/4] Starting Real Video Render..." | tee -a $LOG_FILE
# Simulating a dummy audio for render test
mkdir -p /storage/audio_render
echo "dummy" > /storage/audio_render/test.mp3 

START_TIME=$(date +%s)
python3 ozel/scripts/video_pipeline.py '{"id": "e2e_test", "text": "Testing Full Pipeline Integration", "audio_path": "/storage/audio_render/test.mp3", "format": "16:9"}' >> $LOG_FILE 2>&1
END_TIME=$(date +%s)
RENDER_DURATION=$((END_TIME - START_TIME))
echo "Render duration: $RENDER_DURATION seconds" | tee -a $LOG_FILE

# 3. PUBLISH SIMULATION (DRY RUN)
echo "[3/4] Testing Publisher API (Dry Run)..." | tee -a $LOG_FILE
# We use a non-existent key to trigger the error handling/logging logic
export X_ACCESS_TOKEN="INVALID"
python3 ozel/social_publishers/unified_publisher.py x '{"text": "E2E Test Tweet"}' >> $LOG_FILE 2>&1

# 4. REDIS / WORKER HEALTH
echo "[4/4] Verifying Worker Queue Health..." | tee -a $LOG_FILE
docker exec medya-redis redis-cli -a "${REDIS_PASSWORD:-CHANGE_ME}" info stats | grep "total_commands_processed" >> $LOG_FILE

echo "--- E2E TEST COMPLETE ---" | tee -a $LOG_FILE
echo "Check $LOG_FILE for detailed traces."
