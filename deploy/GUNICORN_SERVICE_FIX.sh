#!/bin/bash
# Gunicorn Service Fix - Permission ve Environment Sorunları
# Kullanım: bash deploy/GUNICORN_SERVICE_FIX.sh

echo "🔧 Gunicorn Service Fix"
echo "======================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. .env dosyası izinleri
echo "🔐 [1/6] .env dosyası izinleri..."
chmod 644 .env
chown www-data:www-data .env
echo "   ✅ .env izinleri güncellendi (www-data okuyabilir)"

# 2. Working directory izinleri
echo ""
echo "📁 [2/6] Working directory izinleri..."
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi
sudo chmod -R 755 /var/www/kutahyaaricilarbirligi
echo "   ✅ Directory izinleri güncellendi"

# 3. Service dosyasını güncelle (daha basit, environment variables direkt)
echo ""
echo "⚙️  [3/6] Gunicorn service dosyası güncelleniyor..."

# .env'den değerleri oku
SECRET_KEY=$(grep DJANGO_SECRET_KEY .env | cut -d= -f2)
ALLOWED_HOSTS=$(grep ALLOWED_HOSTS .env | cut -d= -f2)

sudo tee /etc/systemd/system/gunicorn.service > /dev/null << EOF
[Unit]
Description=Gunicorn daemon for kutahyaaricilarbirligi
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/kutahyaaricilarbirligi
Environment="DJANGO_SECRET_KEY=$SECRET_KEY"
Environment="DEBUG=False"
Environment="ALLOWED_HOSTS=$ALLOWED_HOSTS"
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
echo "   ✅ Service dosyası güncellendi (environment variables direkt)"

# 4. Gunicorn'u başlat
echo ""
echo "🚀 [4/6] Gunicorn başlatılıyor..."
sudo systemctl stop gunicorn 2>/dev/null || true
sleep 2
sudo systemctl start gunicorn
sleep 5

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
    
    # Port kontrolü
    PORT_CHECK=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)
    if [ "$PORT_CHECK" -gt 0 ]; then
        echo "   ✅ Port 8000 açık"
    else
        echo "   ⚠️  Port 8000 henüz açılmadı"
    fi
else
    echo "   ❌ Gunicorn başlatılamadı!"
    echo "   → Log:"
    sudo journalctl -u gunicorn -n 30 --no-pager | tail -20
    
    # Alternatif: root olarak çalıştır (test için)
    echo ""
    echo "   → Alternatif: root kullanıcısı ile test ediliyor..."
    sudo tee /etc/systemd/system/gunicorn.service > /dev/null << EOF
[Unit]
Description=Gunicorn daemon for kutahyaaricilarbirligi
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/var/www/kutahyaaricilarbirligi
Environment="DJANGO_SECRET_KEY=$SECRET_KEY"
Environment="DEBUG=False"
Environment="ALLOWED_HOSTS=$ALLOWED_HOSTS"
ExecStart=/var/www/kutahyaaricilarbirligi/venv/bin/gunicorn \
    --access-logfile - \
    --error-logfile - \
    --workers 2 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    kutahyaaricilarbirligi.wsgi:application

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl start gunicorn
    sleep 5
    
    if sudo systemctl is-active --quiet gunicorn; then
        echo "   ✅ Gunicorn root ile başlatıldı!"
    else
        echo "   ❌ Hala başlatılamadı!"
        exit 1
    fi
fi

# 5. Nginx restart
echo ""
echo "🔄 [5/6] Nginx yeniden başlatılıyor..."
sudo systemctl reload nginx
sleep 2

# 6. Final test
echo ""
echo "🌐 [6/6] Final test..."
sleep 2

# Gunicorn test
GUNICORN_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
echo "   Gunicorn (127.0.0.1:8000): HTTP $GUNICORN_TEST"

# Site test
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$SITE_TEST" = "200" ]; then
    echo ""
    echo "   ✅ Site çalışıyor!"
    echo "   → Test: http://37.148.208.77"
elif [ "$SITE_TEST" = "502" ]; then
    echo ""
    echo "   ❌ Hala 502 Bad Gateway!"
    echo "   → Gunicorn durumu: sudo systemctl status gunicorn"
    echo "   → Port kontrolü: sudo netstat -tlnp | grep 8000"
else
    echo ""
    echo "   ⚠️  Site yanıt veriyor (HTTP $SITE_TEST)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

