#!/bin/bash
# Ubuntu sunucuya deployment script
# Kullanım: bash deploy/deploy.sh

set -e

echo "🚀 Kütahya Arı Yetiştiricileri Birliği - Deployment Başlıyor..."

# Proje dizini
PROJECT_DIR="/var/www/kutahyaaricilarbirligi"
VENV_DIR="$PROJECT_DIR/venv"

# Gerekli paketleri kontrol et
echo "📦 Gerekli paketler kontrol ediliyor..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv postgresql postgresql-contrib nginx certbot python3-certbot-nginx git

# Proje dizinini oluştur
echo "📁 Proje dizini oluşturuluyor..."
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$USER $PROJECT_DIR

# Git'ten projeyi çek (veya mevcut projeyi kopyala)
cd $PROJECT_DIR
if [ ! -d ".git" ]; then
    echo "📥 Proje GitHub'dan çekiliyor..."
    # git clone https://github.com/kullaniciadi/kutahyaaricilarbirligi.git .
fi

# Virtual environment oluştur
echo "🐍 Virtual environment oluşturuluyor..."
python3 -m venv $VENV_DIR
source $VENV_DIR/bin/activate

# Bağımlılıkları yükle
echo "📚 Bağımlılıklar yükleniyor..."
pip install --upgrade pip
pip install -r requirements.txt

# Environment variables dosyası oluştur
echo "⚙️ Environment variables ayarlanıyor..."
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cat > $PROJECT_DIR/.env << EOF
DJANGO_SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GÜVENLİ_ŞİFRE_BURAYA
DB_HOST=localhost
DB_PORT=5432
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com
EOF
    echo "⚠️  .env dosyası oluşturuldu. Lütfen şifreleri güncelleyin!"
fi

# PostgreSQL veritabanı oluştur
echo "🗄️  PostgreSQL veritabanı oluşturuluyor..."
sudo -u postgres psql << EOF
CREATE DATABASE kutahyaaricilarbirligi;
CREATE USER kutahyaaricilarbirligi WITH PASSWORD 'GÜVENLİ_ŞİFRE_BURAYA';
ALTER ROLE kutahyaaricilarbirligi SET client_encoding TO 'utf8';
ALTER ROLE kutahyaaricilarbirligi SET default_transaction_isolation TO 'read committed';
ALTER ROLE kutahyaaricilarbirligi SET timezone TO 'Europe/Istanbul';
GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;
\q
EOF

# Django migrations
echo "🔄 Django migrations çalıştırılıyor..."
python manage.py migrate

# Superuser oluştur (eğer yoksa)
echo "👤 Superuser kontrol ediliyor..."
python manage.py shell << EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@kutahyaaricilarbirligi.com', 'GÜVENLİ_ŞİFRE_BURAYA')
    print("Superuser oluşturuldu: admin")
else:
    print("Superuser zaten mevcut")
EOF

# Static files topla
echo "📦 Static files toplanıyor..."
python manage.py collectstatic --noinput

# Gunicorn service dosyasını kopyala
echo "🔧 Gunicorn service ayarlanıyor..."
sudo cp deploy/gunicorn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn

# Nginx ayarları
echo "🌐 Nginx ayarlanıyor..."
sudo cp deploy/nginx.conf /etc/nginx/sites-available/kutahyaaricilarbirligi
sudo ln -sf /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# SSL Sertifikası
echo "🔒 SSL sertifikası kontrol ediliyor..."
echo "⚠️  NOT: Mevcut SSL sertifikanızı /etc/ssl/certs/ ve /etc/ssl/private/ dizinlerine yükleyin"
echo "⚠️  Sonra /etc/nginx/sites-available/kutahyaaricilarbirligi dosyasındaki ssl_certificate yollarını güncelleyin"
echo "⚠️  Detaylı talimatlar için: deploy/SSL_SERTIFIKA_TALIMATI.md dosyasına bakın"

# Log dizini oluştur
echo "📝 Log dizini oluşturuluyor..."
mkdir -p $PROJECT_DIR/logs
sudo chown -R www-data:www-data $PROJECT_DIR/logs

echo "✅ Deployment tamamlandı!"
echo "🌐 Site: https://www.kutahyaaricilarbirligi.com"
echo "🔐 Admin: https://www.kutahyaaricilarbirligi.com/admin/"


