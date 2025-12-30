#!/bin/bash
# Git Stash ve Pull
# Kullanım: bash deploy/GIT_STASH_VE_PULL.sh

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

# Gunicorn restart
echo ""
echo "🔄 Gunicorn yeniden başlatılıyor..."
source venv/bin/activate
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    exit 1
fi

# Nginx reload
echo ""
echo "🔄 Nginx yeniden yükleniyor..."
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
else
    echo ""
    echo "   ⚠️  Site yanıt veriyor (HTTP $SITE_TEST)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

