#!/bin/bash
# SECRET_KEY Hızlı Çözüm Scripti
# Kullanım: bash deploy/SECRET_KEY_HIZLI_COZUM.sh

echo "🔐 SECRET_KEY Düzeltme"
echo "======================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# Secret key oluştur
echo "🔑 Secret key oluşturuluyor..."
SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

# .env dosyası var mı kontrol et
if [ ! -f ".env" ]; then
    echo "📝 .env dosyası oluşturuluyor..."
    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
EOF
    echo "✅ .env dosyası oluşturuldu!"
else
    echo "⚠️  .env dosyası zaten var. DJANGO_SECRET_KEY güncelleniyor..."
    # Sadece SECRET_KEY'i güncelle
    if grep -q "DJANGO_SECRET_KEY" .env; then
        sed -i "s/^DJANGO_SECRET_KEY=.*/DJANGO_SECRET_KEY=$SECRET_KEY/" .env
    else
        echo "DJANGO_SECRET_KEY=$SECRET_KEY" >> .env
    fi
    echo "✅ SECRET_KEY güncellendi!"
fi

# İzinleri ayarla
chmod 600 .env
chown root:root .env

# Gunicorn service güncelle
echo ""
echo "🔧 Gunicorn service güncelleniyor..."
if ! grep -q "EnvironmentFile" /etc/systemd/system/gunicorn.service; then
    sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service
    echo "✅ EnvironmentFile eklendi!"
else
    echo "✅ EnvironmentFile zaten var."
fi

# Systemd ve Gunicorn'u yeniden başlat
echo ""
echo "🔄 Servisler yeniden başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl restart gunicorn

# Kontrol
echo ""
echo "✅ İşlem tamamlandı!"
echo ""
echo "🔍 Kontrol:"
sudo journalctl -u gunicorn -n 10 | grep -i "secret\|warning" || echo "✅ SECRET_KEY uyarısı yok!"

