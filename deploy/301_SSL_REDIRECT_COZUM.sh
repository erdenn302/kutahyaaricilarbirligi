#!/bin/bash
# 301 SSL Redirect Çözümü
# Kullanım: bash deploy/301_SSL_REDIRECT_COZUM.sh

echo "🔧 301 SSL Redirect Çözümü"
echo "=========================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/3] Git pull..."
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# 2. Gunicorn restart
echo ""
echo "🔄 [2/3] Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    exit 1
fi

# 3. Nginx reload
echo ""
echo "🔄 [3/3] Nginx yeniden yükleniyor..."
sudo systemctl reload nginx
sleep 2

# Test
echo ""
echo "🌐 Test..."
sleep 2

SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$SITE_TEST" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -20)
    if echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya\|Arı"; then
        echo ""
        echo "   ✅ Site çalışıyor!"
        echo "   → Test: http://37.148.208.77"
    else
        echo ""
        echo "   ⚠️  Site yanıt veriyor ama içerik beklenmiyor"
    fi
elif [ "$SITE_TEST" = "301" ]; then
    echo ""
    echo "   ❌ Hala 301 Redirect!"
    echo "   → settings.py'de SECURE_SSL_REDIRECT = False olduğundan emin olun"
    echo "   → Gunicorn'u yeniden başlatın: sudo systemctl restart gunicorn"
else
    echo ""
    echo "   ⚠️  Site yanıt veriyor (HTTP $SITE_TEST)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""
echo "💡 Not: SSL sertifikası yüklendikten sonra settings.py'de:"
echo "   SECURE_SSL_REDIRECT = True"
echo "   SESSION_COOKIE_SECURE = True"
echo "   CSRF_COOKIE_SECURE = True"
echo "   yapın ve Gunicorn'u yeniden başlatın."
echo ""

