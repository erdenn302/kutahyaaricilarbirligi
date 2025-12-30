#!/bin/bash
# 502 Bad Gateway Final Çözüm
# Kullanım: bash deploy/502_FINAL_COZUM.sh

set -e

echo "🔧 502 Bad Gateway Final Çözüm"
echo "================================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. .env dosyası kontrolü
echo "🔐 [1/8] .env dosyası kontrolü..."
if [ ! -f ".env" ]; then
    echo "   ⚠️  .env dosyası yok → Oluşturuluyor..."
    SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
EOF
    chmod 600 .env
    echo "   ✅ .env dosyası oluşturuldu!"
else
    echo "   ✅ .env dosyası var"
fi

# DB satırlarını kaldır (SQLite kullan)
sed -i 's/^DB_/#DB_/g' .env 2>/dev/null || true

# 2. Django check
echo ""
echo "🐍 [2/8] Django check..."
DJANGO_CHECK=$(python manage.py check 2>&1)
if echo "$DJANGO_CHECK" | grep -q "System check identified no issues"; then
    echo "   ✅ Django check başarılı"
else
    echo "   ⚠️  Django check uyarıları var:"
    echo "$DJANGO_CHECK" | grep -i "warning" | head -5 || true
fi

# 3. Database migrate
echo ""
echo "🗄️  [3/8] Database migrate..."
python manage.py migrate --noinput > /dev/null 2>&1
echo "   ✅ Database hazır"

# 4. Static files
echo ""
echo "📁 [4/8] Static files..."
mkdir -p staticfiles media
python manage.py collectstatic --noinput > /dev/null 2>&1
sudo chown -R www-data:www-data staticfiles media
echo "   ✅ Static files hazır"

# 5. Gunicorn service dosyası
echo ""
echo "⚙️  [5/8] Gunicorn service dosyası..."
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
    --workers 2 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    kutahyaaricilarbirligi.wsgi:application

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
echo "   ✅ Service dosyası güncellendi!"

# 6. Gunicorn'u durdur ve başlat
echo ""
echo "🚀 [6/8] Gunicorn başlatılıyor..."
sudo systemctl stop gunicorn 2>/dev/null || true
sleep 2

# Önce manuel test
echo "   → Manuel test (5 saniye)..."
timeout 5 gunicorn kutahyaaricilarbirligi.wsgi:application --bind 127.0.0.1:8000 --workers 1 2>&1 | head -20 &
GUNICORN_TEST_PID=$!
sleep 3
kill $GUNICORN_TEST_PID 2>/dev/null || true
wait $GUNICORN_TEST_PID 2>/dev/null || true

# Service'i başlat
sudo systemctl start gunicorn
sleep 5

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
    
    # Port kontrolü
    PORT_CHECK=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)
    if [ "$PORT_CHECK" -gt 0 ]; then
        echo "   ✅ Port 8000 açık"
    else
        echo "   ⚠️  Port 8000 henüz açılmadı, bekleniyor..."
        sleep 3
    fi
else
    echo "   ❌ Gunicorn başlatılamadı!"
    echo "   → Log:"
    sudo journalctl -u gunicorn -n 30 --no-pager | tail -15
    echo ""
    echo "   → Manuel test çıktısı yukarıda görülebilir"
    exit 1
fi

# 7. Nginx config
echo ""
echo "🌐 [7/8] Nginx config..."
sudo rm -f /etc/nginx/sites-enabled/default

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

sudo rm -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi
sudo ln -sf /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

if sudo nginx -t; then
    echo "   ✅ Nginx config doğru"
else
    echo "   ❌ Nginx config hatası!"
    exit 1
fi

# 8. Nginx restart
echo ""
echo "🔄 [8/8] Nginx yeniden başlatılıyor..."
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

# Final test
echo ""
echo "🌐 Final test..."
sleep 3

# Gunicorn test
GUNICORN_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
echo "   Gunicorn (127.0.0.1:8000): HTTP $GUNICORN_TEST"

# Site test
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$SITE_TEST" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -20)
    if echo "$CONTENT" | grep -qi "Welcome to nginx"; then
        echo ""
        echo "   ⚠️  Hala Nginx varsayılan sayfası görünüyor"
    elif echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya"; then
        echo ""
        echo "   ✅ Site çalışıyor!"
        echo "   → Test: http://37.148.208.77"
    else
        echo ""
        echo "   ⚠️  Site yanıt veriyor ama içerik beklenmiyor"
    fi
elif [ "$SITE_TEST" = "502" ]; then
    echo ""
    echo "   ❌ Hala 502 Bad Gateway!"
    echo ""
    echo "   🔍 Kontrol:"
    echo "   1. Gunicorn: sudo systemctl status gunicorn"
    echo "   2. Port 8000: sudo netstat -tlnp | grep 8000"
    echo "   3. Gunicorn log: sudo journalctl -u gunicorn -n 50"
    echo "   4. Nginx log: sudo tail -50 /var/log/nginx/error.log"
else
    echo ""
    echo "   ❌ Site erişilemiyor (HTTP $SITE_TEST)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

