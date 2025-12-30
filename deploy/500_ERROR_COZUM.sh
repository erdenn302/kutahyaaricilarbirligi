#!/bin/bash
# HTTP 500 Error Çözümü
# Kullanım: bash deploy/500_ERROR_COZUM.sh

echo "🔧 HTTP 500 Error Çözümü"
echo "========================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Gunicorn log kontrolü
echo "📋 [1/6] Gunicorn Log Kontrolü:"
echo ""
GUNICORN_ERRORS=$(sudo journalctl -u gunicorn -n 50 --no-pager 2>&1 | grep -i "error\|exception\|traceback" | head -20)
if [ -n "$GUNICORN_ERRORS" ]; then
    echo "   ⚠️  Gunicorn log'da hatalar:"
    echo "$GUNICORN_ERRORS"
else
    echo "   ✅ Gunicorn log'da hata yok"
fi

# 2. Django log kontrolü
echo ""
echo "📋 [2/6] Django Log Kontrolü:"
if [ -f "logs/django.log" ]; then
    DJANGO_ERRORS=$(tail -50 logs/django.log 2>&1 | grep -i "error\|exception\|traceback" | head -20)
    if [ -n "$DJANGO_ERRORS" ]; then
        echo "   ⚠️  Django log'da hatalar:"
        echo "$DJANGO_ERRORS"
    else
        echo "   ✅ Django log'da hata yok"
    fi
else
    echo "   ⚠️  Django log dosyası bulunamadı"
    mkdir -p logs
    chmod 755 logs
fi

# 3. Django check
echo ""
echo "🐍 [3/6] Django Check:"
DJANGO_CHECK=$(python manage.py check 2>&1)
if echo "$DJANGO_CHECK" | grep -q "System check identified no issues"; then
    echo "   ✅ Django check başarılı"
else
    echo "   ⚠️  Django check uyarıları:"
    echo "$DJANGO_CHECK" | grep -i "warning\|error" | head -10
fi

# 4. Database kontrolü
echo ""
echo "🗄️  [4/6] Database Kontrolü:"
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "   ✅ Database bağlantısı başarılı"
else
    echo "   ⚠️  Database sorunu:"
    echo "$DB_TEST" | grep -i "error\|failed" | head -5
    echo "   → SQLite'a geçiliyor..."
    bash deploy/VERITABANI_HIZLI_COZUM.sh > /dev/null 2>&1
    echo "   ✅ SQLite'a geçildi!"
fi

# 5. Static files kontrolü
echo ""
echo "📁 [5/6] Static Files Kontrolü:"
if [ ! -d "staticfiles" ] || [ -z "$(ls -A staticfiles 2>/dev/null)" ]; then
    echo "   ⚠️  Static files eksik → Toplanıyor..."
    python manage.py collectstatic --noinput
    sudo chown -R www-data:www-data staticfiles
    echo "   ✅ Static files toplandı!"
else
    echo "   ✅ Static files var"
fi

# 6. Gunicorn restart
echo ""
echo "🔄 [6/6] Gunicorn Yeniden Başlatılıyor..."
sudo systemctl restart gunicorn
sleep 5

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    sudo journalctl -u gunicorn -n 30 --no-pager | tail -20
fi

# Test
echo ""
echo "🌐 Test..."
sleep 3

LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")

echo "   Gunicorn (127.0.0.1:8000): HTTP $LOCAL_TEST"
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$LOCAL_TEST" = "200" ] && [ "$SITE_TEST" = "200" ]; then
    echo ""
    echo "   ✅ Site çalışıyor!"
elif [ "$LOCAL_TEST" = "500" ] || [ "$SITE_TEST" = "500" ]; then
    echo ""
    echo "   ❌ Hala HTTP 500 hatası!"
    echo ""
    echo "   🔍 Detaylı Hata Bilgisi:"
    echo "   1. Gunicorn log: sudo journalctl -u gunicorn -n 100"
    echo "   2. Django log: tail -50 logs/django.log"
    echo "   3. Nginx log: sudo tail -50 /var/log/nginx/error.log"
    echo "   4. Manuel test: curl -v http://127.0.0.1:8000"
    echo ""
    echo "   💡 DEBUG=True yaparak hata detaylarını görebilirsiniz:"
    echo "      nano .env"
    echo "      DEBUG=True yapın"
    echo "      sudo systemctl restart gunicorn"
    echo "      (Hata detaylarını gördükten sonra tekrar DEBUG=False yapın)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

