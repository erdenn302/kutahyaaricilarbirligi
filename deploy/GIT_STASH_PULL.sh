#!/bin/bash
# Git Stash ve Pull - Local Değişiklikleri Sakla
# Kullanım: bash deploy/GIT_STASH_PULL.sh

echo "🔄 Git Stash ve Pull"
echo "==================="
echo ""

cd /var/www/kutahyaaricilarbirligi

# Local değişiklikleri stash et
echo "📦 Local değişiklikler stash ediliyor..."
git stash
echo "   ✅ Stash tamamlandı!"

# Pull yap
echo ""
echo "📥 Git pull yapılıyor..."
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# Staticfiles çözümü
echo ""
echo "🔧 Staticfiles manifest sorunu çözülüyor..."
source venv/bin/activate

# Static klasörü kontrolü
if [ ! -f "static/css/main.css" ]; then
    mkdir -p static/css
    touch static/css/main.css
fi

# Staticfiles temizle ve topla
rm -rf staticfiles/*
python manage.py collectstatic --noinput --clear
sudo chown -R www-data:www-data staticfiles
echo "   ✅ Staticfiles yeniden toplandı!"

# Gunicorn restart
echo ""
echo "🔄 Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    exit 1
fi

# Test
echo ""
echo "🌐 Test..."
sleep 2

LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")

echo "   Gunicorn (127.0.0.1:8000): HTTP $LOCAL_TEST"
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$LOCAL_TEST" = "200" ] && [ "$SITE_TEST" = "200" ]; then
    echo ""
    echo "   ✅ Site çalışıyor!"
    echo "   → Test: http://37.148.208.77"
elif [ "$LOCAL_TEST" = "500" ] || [ "$SITE_TEST" = "500" ]; then
    echo ""
    echo "   ❌ Hala HTTP 500 hatası!"
    echo "   → Log kontrolü: sudo journalctl -u gunicorn -n 50"
else
    echo ""
    echo "   ⚠️  Site yanıt: HTTP $SITE_TEST"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

