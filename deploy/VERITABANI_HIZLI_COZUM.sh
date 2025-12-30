#!/bin/bash
# Veritabanı Hızlı Çözüm - SQLite'a Geç
# Kullanım: bash deploy/VERITABANI_HIZLI_COZUM.sh

echo "🗄️  Veritabanı Hızlı Çözüm"
echo "============================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# .env dosyasını yedekle
if [ -f ".env" ]; then
    cp .env .env.backup
    echo "✅ .env dosyası yedeklendi (.env.backup)"
fi

# .env dosyasını güncelle (DB satırlarını kaldır)
if [ -f ".env" ]; then
    # DB satırlarını yorum satırı yap
    sed -i 's/^DB_/#DB_/g' .env
    echo "✅ DB satırları yorum satırı yapıldı (SQLite kullanılacak)"
else
    # .env dosyası yoksa oluştur
    SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
# PostgreSQL yerine SQLite kullanılıyor
# DB_NAME=kutahyaaricilarbirligi
# DB_USER=kutahyaaricilarbirligi
# DB_PASSWORD=GucluSifre_2025!
# DB_HOST=localhost
# DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
EOF
    chmod 600 .env
    chown root:root .env
    echo "✅ .env dosyası oluşturuldu (SQLite ile)"
fi

# Migrations çalıştır
echo ""
echo "🗄️  Migrations çalıştırılıyor..."
python manage.py migrate
echo "✅ Migrations tamamlandı!"

# Static files
echo ""
echo "📁 Static files toplanıyor..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
echo "✅ Static files toplandı!"

# Gunicorn restart
echo ""
echo "🔄 Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
echo "✅ Gunicorn yeniden başlatıldı!"

# Test
echo ""
echo "🔍 Test ediliyor..."
python manage.py check
echo ""

echo "======================================"
echo "✅ SQLite'a geçiş tamamlandı!"
echo ""
echo "📝 Not: PostgreSQL kullanmak isterseniz:"
echo "   1. deploy/POSTGRESQL_KURULUM.md dosyasına bakın"
echo "   2. .env.backup dosyasını geri yükleyin"
echo ""

