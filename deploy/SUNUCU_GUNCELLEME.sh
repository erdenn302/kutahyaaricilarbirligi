#!/bin/bash
# Sunucu Güncelleme Scripti
# Kullanım: bash deploy/SUNUCU_GUNCELLEME.sh

echo "🔄 Sunucu Güncelleme"
echo "===================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull (stash ile)
echo "📥 Git pull yapılıyor..."
git stash
git pull origin main
echo "✅ Git pull tamamlandı!"

# 2. python-dotenv kur
echo ""
echo "📦 python-dotenv kuruluyor..."
pip install python-dotenv
echo "✅ python-dotenv kuruldu!"

# 3. .env dosyası kontrolü
echo ""
echo "🔐 .env dosyası kontrol ediliyor..."
if [ ! -f ".env" ]; then
    echo "⚠️  .env dosyası bulunamadı. Oluşturuluyor..."
    SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
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
    chmod 600 .env
    chown root:root .env
    echo "✅ .env dosyası oluşturuldu!"
else
    echo "✅ .env dosyası zaten var."
fi

# 4. Requirements güncelle
echo ""
echo "📦 Requirements güncelleniyor..."
pip install -r requirements.txt
echo "✅ Requirements güncellendi!"

# 5. Migrations
echo ""
echo "🗄️  Migrations çalıştırılıyor..."
python manage.py migrate
echo "✅ Migrations tamamlandı!"

# 6. Static files
echo ""
echo "📁 Static files toplanıyor..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
echo "✅ Static files toplandı!"

# 7. Gunicorn restart
echo ""
echo "🔄 Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
echo "✅ Gunicorn yeniden başlatıldı!"

# 8. Kontrol
echo ""
echo "🔍 Kontroller..."
echo ""
echo "📊 SECRET_KEY uyarısı kontrolü:"
python manage.py check 2>&1 | grep -i "SECRET_KEY" || echo "✅ SECRET_KEY uyarısı yok!"

echo ""
echo "📊 Servis durumları:"
sudo systemctl is-active nginx && echo "✅ Nginx çalışıyor" || echo "❌ Nginx çalışmıyor"
sudo systemctl is-active gunicorn && echo "✅ Gunicorn çalışıyor" || echo "❌ Gunicorn çalışmıyor"

echo ""
echo "======================================"
echo "✅ Güncelleme tamamlandı!"
echo ""

