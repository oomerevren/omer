#!/bin/bash
set -e

echo "🌍 Otonom Medya Holdingi (v2.0) Kurulum Başlatılıyor..."

# .env dosyası kontrolü
if [ ! -f .env ]; then
    echo "📝 .env dosyası oluşturuluyor..."
    cp .env.example .env
    # Güvenli şifreler üret
    sed -i "s/POSTGRES_PASSWORD=CHANGE_ME/POSTGRES_PASSWORD=$(openssl rand -base64 12)/" .env
    sed -i "s/N8N_ENCRYPTION_KEY=CHANGE_ME/N8N_ENCRYPTION_KEY=$(openssl rand -base64 24)/" .env
    sed -i "s/REDIS_PASSWORD=CHANGE_ME/REDIS_PASSWORD=$(openssl rand -base64 12)/" .env
    echo "✅ .env dosyası oluşturuldu. Lütfen LLM API anahtarlarını ekleyin!"
fi

# Klasörleri oluştur
mkdir -p backups config/nginx config/prometheus config/grafana

# Servisleri başlat
echo "🚀 Servisler başlatılıyor..."
docker compose up -d

echo ""
echo "✅ Kurulum tamamlandı!"
echo "🌐 Gateway: http://localhost"
echo "🤖 n8n: http://localhost/automation"
echo "📦 CMS: http://localhost:8055"
echo ""
echo "📋 Sonraki Adımlar:"
echo "1. .env dosyasına MISTRAL_API_KEY ekleyin."
echo "2. n8n üzerinde Cloud API kimlik bilgilerini tanımlayın."
echo "3. Workflow'ları aktif hale getirin."
