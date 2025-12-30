#!/bin/bash
# 400 Bad Request Çözümü - ALLOWED_HOSTS
# Kullanım: bash deploy/400_BAD_REQUEST_COZUM.sh

echo "🔧 400 Bad Request Çözümü"
echo "========================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. .env dosyasını güncelle
echo "🔐 [1/4] .env dosyası güncelleniyor..."
if [ -f ".env" ]; then
    # ALLOWED_HOSTS'i güncelle (IP adresini ekle)
    if grep -q "ALLOWED_HOSTS" .env; then
        sed -i 's/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77,localhost,127.0.0.1/' .env
    else
        echo "ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77,localhost,127.0.0.1" >> .env
    fi
    echo "   ✅ ALLOWED_HOSTS güncellendi"
else
    echo "   ⚠️  .env dosyası yok → Oluşturuluyor..."
    SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77,localhost,127.0.0.1
EOF
    chmod 644 .env
    chown www-data:www-data .env
    echo "   ✅ .env dosyası oluşturuldu"
fi

# 2. settings.py kontrolü (ALLOWED_HOSTS'in environment'tan okunduğundan emin ol)
echo ""
echo "⚙️  [2/4] settings.py kontrolü..."
if grep -q "ALLOWED_HOSTS = os.environ.get" kutahyaaricilarbirligi/settings.py; then
    echo "   ✅ settings.py ALLOWED_HOSTS environment'tan okuyor"
else
    echo "   ⚠️  settings.py'de ALLOWED_HOSTS kontrol edilmeli"
fi

# 3. Gunicorn service dosyasını güncelle
echo ""
echo "⚙️  [3/4] Gunicorn service dosyası güncelleniyor..."

# .env'den değerleri oku
SECRET_KEY=$(grep DJANGO_SECRET_KEY .env | cut -d= -f2)
ALLOWED_HOSTS=$(grep ALLOWED_HOSTS .env | cut -d= -f2)

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
echo "   ✅ Service dosyası güncellendi"

# 4. Gunicorn restart
echo ""
echo "🔄 [4/4] Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    sudo journalctl -u gunicorn -n 20 --no-pager
    exit 1
fi

# Nginx restart
sudo systemctl reload nginx

# Test
echo ""
echo "🌐 Test..."
sleep 2

SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$SITE_TEST" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -20)
    if echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya"; then
        echo ""
        echo "   ✅ Site çalışıyor!"
        echo "   → Test: http://37.148.208.77"
    else
        echo ""
        echo "   ⚠️  Site yanıt veriyor ama içerik beklenmiyor"
    fi
elif [ "$SITE_TEST" = "400" ]; then
    echo ""
    echo "   ❌ Hala 400 Bad Request!"
    echo ""
    echo "   🔍 Kontrol:"
    echo "   1. .env dosyası: cat .env | grep ALLOWED_HOSTS"
    echo "   2. Gunicorn environment: sudo systemctl show gunicorn | grep ALLOWED"
    echo "   3. Django check: python manage.py check"
elif [ "$SITE_TEST" = "502" ]; then
    echo ""
    echo "   ❌ 502 Bad Gateway!"
    echo "   → Gunicorn durumu: sudo systemctl status gunicorn"
else
    echo ""
    echo "   ⚠️  Site yanıt veriyor (HTTP $SITE_TEST)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

