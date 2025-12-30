#!/bin/bash
# Staticfiles Manifest Sorunu Çözümü
# Kullanım: bash deploy/STATICFILES_MANIFEST_COZUM.sh

echo "🔧 Staticfiles Manifest Sorunu Çözümü"
echo "======================================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/4] Git pull..."
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# 2. Static klasörü kontrolü
echo ""
echo "📁 [2/4] Static klasörü kontrolü..."
if [ -f "static/css/main.css" ]; then
    echo "   ✅ static/css/main.css var"
else
    echo "   ❌ static/css/main.css bulunamadı!"
    echo "   → Dosya oluşturuluyor..."
    mkdir -p static/css
    touch static/css/main.css
    echo "   ✅ Dosya oluşturuldu!"
fi

# 3. Staticfiles temizle ve yeniden topla
echo ""
echo "📦 [3/4] Staticfiles temizleniyor ve yeniden toplanıyor..."
rm -rf staticfiles/*
python manage.py collectstatic --noinput --clear
sudo chown -R www-data:www-data staticfiles
echo "   ✅ Staticfiles yeniden toplandı!"

# 4. Gunicorn restart
echo ""
echo "🔄 [4/4] Gunicorn yeniden başlatılıyor..."
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

