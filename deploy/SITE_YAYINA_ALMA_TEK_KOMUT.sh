#!/bin/bash
# Site Yayına Alma - Tek Komut
# Kullanım: bash deploy/SITE_YAYINA_ALMA_TEK_KOMUT.sh

set -e  # Hata durumunda dur

echo "🚀 Site Yayına Alma Başlatılıyor..."
echo "======================================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/12] Git pull yapılıyor..."
git stash > /dev/null 2>&1 || true
git pull origin main
echo "✅ Git pull tamamlandı!"

# 2. python-dotenv kur
echo ""
echo "📦 [2/12] python-dotenv kuruluyor..."
pip install -q python-dotenv
echo "✅ python-dotenv kuruldu!"

# 3. .env dosyası oluştur
echo ""
echo "🔐 [3/12] .env dosyası oluşturuluyor..."
if [ ! -f ".env" ]; then
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

# 4. Static klasörü oluştur
echo ""
echo "📁 [4/12] Static klasörü oluşturuluyor..."
mkdir -p static/css static/js static/images
chmod -R 755 static
echo "✅ Static klasörü oluşturuldu!"

# 5. Requirements güncelle
echo ""
echo "📦 [5/12] Requirements güncelleniyor..."
pip install -q -r requirements.txt
echo "✅ Requirements güncellendi!"

# 6. Migrations
echo ""
echo "🗄️  [6/12] Migrations çalıştırılıyor..."
python manage.py migrate --noinput
echo "✅ Migrations tamamlandı!"

# 7. Static files
echo ""
echo "📁 [7/12] Static files toplanıyor..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
echo "✅ Static files toplandı!"

# 8. Gunicorn service güncelle
echo ""
echo "🔧 [8/12] Gunicorn service güncelleniyor..."
if ! grep -q "EnvironmentFile" /etc/systemd/system/gunicorn.service 2>/dev/null; then
    sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service
    echo "✅ EnvironmentFile eklendi!"
else
    echo "✅ EnvironmentFile zaten var."
fi

# 9. Gunicorn restart
echo ""
echo "🔄 [9/12] Gunicorn yeniden başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
sleep 2
echo "✅ Gunicorn yeniden başlatıldı!"

# 10. Nginx kontrolü
echo ""
echo "🌐 [10/12] Nginx kontrol ediliyor..."
if ! sudo systemctl is-active --quiet nginx; then
    sudo systemctl start nginx
    echo "✅ Nginx başlatıldı!"
else
    echo "✅ Nginx zaten çalışıyor."
fi

# 11. Servis durumları
echo ""
echo "📊 [11/12] Servis durumları kontrol ediliyor..."
NGINX_STATUS=$(sudo systemctl is-active nginx)
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn)

if [ "$NGINX_STATUS" = "active" ]; then
    echo "✅ Nginx: Çalışıyor"
else
    echo "❌ Nginx: Çalışmıyor"
fi

if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "✅ Gunicorn: Çalışıyor"
else
    echo "❌ Gunicorn: Çalışmıyor"
fi

# 12. Site test
echo ""
echo "🌐 [12/12] Site test ediliyor..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Site çalışıyor! (HTTP $HTTP_CODE)"
else
    echo "⚠️  Site yanıt vermiyor (HTTP $HTTP_CODE)"
fi

# SECRET_KEY kontrolü
echo ""
echo "🔐 SECRET_KEY uyarısı kontrol ediliyor..."
if python manage.py check 2>&1 | grep -q "SECRET_KEY"; then
    echo "⚠️  SECRET_KEY uyarısı hala var!"
else
    echo "✅ SECRET_KEY uyarısı yok!"
fi

echo ""
echo "======================================"
echo "🎉 Yayına alma işlemi tamamlandı!"
echo ""
echo "🌐 Site Adresleri:"
echo "   - http://kutahyaaricilarbirligi.com"
echo "   - http://www.kutahyaaricilarbirligi.com"
echo "   - http://37.148.208.77"
echo ""
echo "📝 Sonraki Adımlar:"
echo "   1. Admin panelinden içerik ekleyin: http://kutahyaaricilarbirligi.com/admin/"
echo "   2. Logo yükleyin (Site Ayarları)"
echo "   3. SSL sertifikası ekleyin (opsiyonel)"
echo ""

