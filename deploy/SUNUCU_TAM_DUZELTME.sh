#!/bin/bash
# Sunucu Tam Düzeltme - Tüm Sorunları Çöz
# Kullanım: bash deploy/SUNUCU_TAM_DUZELTME.sh

set -e  # Hata durumunda dur

echo "🔧 Sunucu Tam Düzeltme"
echo "======================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/12] Git pull..."
git stash > /dev/null 2>&1 || true
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# 2. python-dotenv kur
echo ""
echo "📦 [2/12] python-dotenv kontrolü..."
if ! pip list | grep -q python-dotenv; then
    pip install -q python-dotenv
    echo "   ✅ python-dotenv kuruldu!"
else
    echo "   ✅ python-dotenv zaten kurulu"
fi

# 3. .env dosyası
echo ""
echo "🔐 [3/12] .env dosyası kontrolü..."
if [ ! -f ".env" ]; then
    echo "   ⚠️  .env dosyası yok → Oluşturuluyor..."
    SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
EOF
    chmod 600 .env
    chown root:root .env
    echo "   ✅ .env dosyası oluşturuldu!"
else
    echo "   ✅ .env dosyası var"
    # SECRET_KEY kontrolü
    if ! grep -q "DJANGO_SECRET_KEY" .env; then
        SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
        echo "DJANGO_SECRET_KEY=$SECRET_KEY" >> .env
        echo "   ✅ SECRET_KEY eklendi!"
    fi
fi

# 4. Static ve Media klasörleri
echo ""
echo "📁 [4/12] Static ve Media klasörleri..."
mkdir -p static/css static/js static/images
mkdir -p media
mkdir -p staticfiles
chmod -R 755 static
chmod -R 755 media
echo "   ✅ Klasörler oluşturuldu!"

# 5. Database (SQLite)
echo ""
echo "🗄️  [5/12] Database (SQLite)..."
# .env'den DB satırlarını kaldır
sed -i 's/^DB_/#DB_/g' .env 2>/dev/null || true
python manage.py migrate --noinput
echo "   ✅ Database hazır!"

# 6. Static files
echo ""
echo "📁 [6/12] Static files..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
sudo chown -R www-data:www-data media
echo "   ✅ Static files toplandı!"

# 7. Logs klasörü
echo ""
echo "📋 [7/12] Logs klasörü..."
mkdir -p logs
chmod 755 logs
echo "   ✅ Logs klasörü hazır!"

# 8. Gunicorn service dosyası
echo ""
echo "⚙️  [8/12] Gunicorn service dosyası..."
if [ ! -f "/etc/systemd/system/gunicorn.service" ]; then
    echo "   ⚠️  Service dosyası yok → Oluşturuluyor..."
    sudo tee /etc/systemd/system/gunicorn.service > /dev/null << 'EOF'
[Unit]
Description=Gunicorn daemon for kutahyaaricilarbirligi
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/kutahyaaricilarbirligi
EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env
ExecStart=/var/www/kutahyaaricilarbirligi/venv/bin/gunicorn \
    --access-logfile - \
    --error-logfile - \
    --workers 3 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    kutahyaaricilarbirligi.wsgi:application

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    echo "   ✅ Service dosyası oluşturuldu!"
else
    echo "   ✅ Service dosyası var"
    # EnvironmentFile kontrolü
    if ! grep -q "EnvironmentFile" /etc/systemd/system/gunicorn.service; then
        echo "   ⚠️  EnvironmentFile yok → Ekleniyor..."
        sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service
        echo "   ✅ EnvironmentFile eklendi!"
    fi
fi

sudo systemctl daemon-reload
echo "   ✅ Systemd reload edildi!"

# 9. Gunicorn başlat
echo ""
echo "🚀 [9/12] Gunicorn başlatılıyor..."
sudo systemctl stop gunicorn 2>/dev/null || true
sleep 2
sudo systemctl start gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    echo "   → Log kontrolü:"
    sudo journalctl -u gunicorn -n 20 --no-pager | tail -10
    echo ""
    echo "   → Manuel test:"
    echo "     cd /var/www/kutahyaaricilarbirligi"
    echo "     source venv/bin/activate"
    echo "     gunicorn kutahyaaricilarbirligi.wsgi:application --bind 127.0.0.1:8000"
fi

# 10. Nginx config
echo ""
echo "🌐 [10/12] Nginx config..."
# Varsayılan config'i sil
sudo rm -f /etc/nginx/sites-enabled/default

# Django config'i oluştur
sudo tee /etc/nginx/sites-available/kutahyaaricilarbirligi > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    client_max_body_size 10M;
    
    location /static/ {
        alias /var/www/kutahyaaricilarbirligi/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    location /media/ {
        alias /var/www/kutahyaaricilarbirligi/media/;
        expires 7d;
        add_header Cache-Control "public";
    }
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Symlink
sudo rm -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi
sudo ln -sf /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# Config test
if sudo nginx -t; then
    echo "   ✅ Nginx config doğru!"
else
    echo "   ❌ Nginx config hatası!"
    exit 1
fi

# 11. Nginx restart
echo ""
echo "🔄 [11/12] Nginx yeniden başlatılıyor..."
sudo systemctl stop nginx
sleep 1
sudo systemctl start nginx
sleep 2

if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx başlatıldı!"
else
    echo "   ❌ Nginx başlatılamadı!"
    sudo tail -20 /var/log/nginx/error.log
    exit 1
fi

# 12. Final test
echo ""
echo "🌐 [12/12] Final test..."
sleep 2

# Gunicorn test
GUNICORN_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
if [ "$GUNICORN_TEST" = "200" ]; then
    echo "   ✅ Gunicorn çalışıyor (HTTP $GUNICORN_TEST)"
else
    echo "   ❌ Gunicorn yanıt vermiyor (HTTP $GUNICORN_TEST)"
fi

# Site test
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
if [ "$SITE_TEST" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -30)
    if echo "$CONTENT" | grep -qi "Welcome to nginx"; then
        echo "   ⚠️  Hala Nginx varsayılan sayfası (HTTP $SITE_TEST)"
    elif echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya\|Arı"; then
        echo "   ✅ Site çalışıyor! (HTTP $SITE_TEST)"
        echo "   → Test: http://37.148.208.77"
    else
        echo "   ⚠️  Site yanıt veriyor (HTTP $SITE_TEST)"
    fi
else
    echo "   ❌ Site erişilemiyor (HTTP $SITE_TEST)"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

echo "🔍 Servis Durumları:"
sudo systemctl is-active nginx && echo "   ✅ Nginx: Çalışıyor" || echo "   ❌ Nginx: Çalışmıyor"
sudo systemctl is-active gunicorn && echo "   ✅ Gunicorn: Çalışıyor" || echo "   ❌ Gunicorn: Çalışmıyor"

echo ""
echo "🔌 Port Kontrolü:"
sudo netstat -tlnp 2>/dev/null | grep ":80 " && echo "   ✅ Port 80: Açık" || echo "   ❌ Port 80: Kapalı"
sudo netstat -tlnp 2>/dev/null | grep ":8000 " && echo "   ✅ Port 8000: Açık" || echo "   ❌ Port 8000: Kapalı"

echo ""
echo "💡 Sorun devam ederse:"
echo "   1. Gunicorn log: sudo journalctl -u gunicorn -n 50"
echo "   2. Nginx log: sudo tail -50 /var/log/nginx/error.log"
echo "   3. Django check: python manage.py check"
echo "   4. Manuel test: gunicorn kutahyaaricilarbirligi.wsgi:application --bind 127.0.0.1:8000"
echo ""

