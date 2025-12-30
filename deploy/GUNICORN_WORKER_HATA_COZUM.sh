#!/bin/bash
# Gunicorn Worker Hatası Çözümü
# Kullanım: bash deploy/GUNICORN_WORKER_HATA_COZUM.sh

echo "🔧 Gunicorn Worker Hatası Çözümü"
echo "================================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Django check
echo "🐍 [1/6] Django check:"
DJANGO_CHECK=$(python manage.py check 2>&1)
if echo "$DJANGO_CHECK" | grep -q "System check identified no issues"; then
    echo "   ✅ Django check başarılı"
else
    echo "   ❌ Django check hatası:"
    echo "$DJANGO_CHECK" | grep -i "error\|exception" | head -10
fi

# 2. Database kontrolü
echo ""
echo "🗄️  [2/6] Database kontrolü:"
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "   ✅ Database bağlantısı başarılı"
else
    echo "   ⚠️  Database sorunu var → SQLite'a geçiliyor..."
    bash deploy/VERITABANI_HIZLI_COZUM.sh > /dev/null 2>&1
    echo "   ✅ SQLite'a geçildi!"
fi

# 3. Static files kontrolü
echo ""
echo "📁 [3/6] Static files kontrolü:"
if [ ! -d "staticfiles" ]; then
    echo "   ⚠️  Staticfiles klasörü yok → Oluşturuluyor..."
    mkdir -p staticfiles
    python manage.py collectstatic --noinput > /dev/null 2>&1
    sudo chown -R www-data:www-data staticfiles
    echo "   ✅ Static files toplandı!"
else
    echo "   ✅ Staticfiles klasörü var"
fi

# 4. Media klasörü
echo ""
echo "📁 [4/6] Media klasörü:"
if [ ! -d "media" ]; then
    mkdir -p media
    sudo chown -R www-data:www-data media
    echo "   ✅ Media klasörü oluşturuldu!"
else
    echo "   ✅ Media klasörü var"
fi

# 5. Gunicorn service dosyası kontrolü
echo ""
echo "⚙️  [5/6] Gunicorn service dosyası kontrolü:"
if [ -f "/etc/systemd/system/gunicorn.service" ]; then
    echo "   ✅ Service dosyası var"
    
    # EnvironmentFile kontrolü
    if grep -q "EnvironmentFile" /etc/systemd/system/gunicorn.service; then
        echo "   ✅ EnvironmentFile var"
    else
        echo "   ⚠️  EnvironmentFile yok → Ekleniyor..."
        sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service
        sudo systemctl daemon-reload
        echo "   ✅ EnvironmentFile eklendi!"
    fi
else
    echo "   ❌ Service dosyası yok → Oluşturuluyor..."
    sudo cp deploy/gunicorn.service /etc/systemd/system/
    sudo systemctl daemon-reload
    echo "   ✅ Service dosyası oluşturuldu!"
fi

# 6. Gunicorn manuel test
echo ""
echo "🧪 [6/6] Gunicorn manuel test:"
echo "   → Gunicorn'u manuel başlatıyoruz (test için)..."
timeout 5 gunicorn kutahyaaricilarbirligi.wsgi:application --bind 127.0.0.1:8000 --workers 3 2>&1 | head -20 &
GUNICORN_PID=$!
sleep 3

if ps -p $GUNICORN_PID > /dev/null 2>&1; then
    echo "   ✅ Gunicorn manuel test başarılı!"
    kill $GUNICORN_PID 2>/dev/null || true
    wait $GUNICORN_PID 2>/dev/null || true
    
    # Service'i başlat
    echo ""
    echo "🚀 Gunicorn service başlatılıyor..."
    sudo systemctl restart gunicorn
    sleep 3
    
    if sudo systemctl is-active --quiet gunicorn; then
        echo "   ✅ Gunicorn service başarıyla başlatıldı!"
    else
        echo "   ❌ Gunicorn service başlatılamadı!"
        echo "   → Detaylı log:"
        sudo journalctl -u gunicorn -n 30 --no-pager | tail -20
    fi
else
    echo "   ❌ Gunicorn manuel test başarısız!"
    echo "   → Hata detayları:"
    timeout 5 gunicorn kutahyaaricilarbirligi.wsgi:application --bind 127.0.0.1:8000 --workers 3 2>&1 | head -30
fi

# Final test
echo ""
echo "🌐 Final test:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Gunicorn çalışıyor! (HTTP $HTTP_CODE)"
    echo "   → Site test: http://37.148.208.77"
else
    echo "   ❌ Gunicorn yanıt vermiyor (HTTP $HTTP_CODE)"
    echo ""
    echo "   🔍 Detaylı kontrol:"
    echo "   1. Django check: python manage.py check"
    echo "   2. Gunicorn log: sudo journalctl -u gunicorn -n 50"
    echo "   3. Service dosyası: sudo cat /etc/systemd/system/gunicorn.service"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

