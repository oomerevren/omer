#!/bin/bash
# Otonom Medya Holdingi - Integration Tests

echo "🧪 Starting Integration Tests..."

check_service() {
    if docker ps | grep -q "$1"; then
        echo "✅ Service $1 is running."
    else
        echo "❌ Service $1 is NOT running."
        exit 1
    fi
}

# 1. Check Container Status
check_service "medya-postgres"
check_service "medya-redis"
check_service "medya-n8n"
check_service "medya-cms"
check_service "medya-worker"

# 2. Check Database Connectivity
echo "🗄️ Checking DB Connectivity..."
docker exec medya-postgres pg_isready -U "${POSTGRES_USER:-medya_user}" > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Database is ready."
else
    echo "❌ Database is NOT ready."
    exit 1
fi

# 3. Check Vector Extension
echo "📐 Checking pgvector..."
VECTOR_EXISTS=$(docker exec medya-postgres psql -U "${POSTGRES_USER:-medya_user}" -d "${POSTGRES_DB:-medya_db}" -tAc "SELECT count(*) FROM pg_extension WHERE extname='vector';")
if [ "$VECTOR_EXISTS" -eq "1" ]; then
    echo "✅ pgvector extension is installed."
else
    echo "❌ pgvector extension is MISSING."
    exit 1
fi

echo "🎉 All integration tests passed!"
