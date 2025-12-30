#!/bin/bash
# Mobil Düzenleme Yükleme Scripti
# Kullanım: bash deploy/MOBIL_DUZENLEME_YUKLEME.sh

echo "📱 Mobil Düzenleme Yükleme"
echo "=========================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/4] Git pull..."
git stash > /dev/null 2>&1 || true
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# 2. Static files topla
echo ""
echo "📁 [2/4] Static files toplanıyor..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
echo "   ✅ Static files toplandı!"

# 3. Gunicorn restart
echo ""
echo "🔄 [3/4] Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    exit 1
fi

# 4. Nginx reload
echo ""
echo "🔄 [4/4] Nginx yeniden yükleniyor..."
sudo systemctl reload nginx
sleep 2

# Test
echo ""
echo "🌐 Test..."
sleep 2

SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site (37.148.208.77): HTTP $SITE_TEST"

if [ "$SITE_TEST" = "200" ]; then
    echo ""
    echo "   ✅ Site çalışıyor!"
    echo "   → Mobil görünüm iyileştirmeleri yüklendi"
    echo "   → Test: http://37.148.208.77 (mobil cihazdan veya tarayıcı responsive mode)"
else
    echo ""
    echo "   ⚠️  Site yanıt: HTTP $SITE_TEST"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""
echo "📱 Mobil İyileştirmeler:"
echo "   ✅ Responsive font boyutları"
echo "   ✅ Mobil uyumlu butonlar"
echo "   ✅ Optimize edilmiş kartlar"
echo "   ✅ Mobil navbar"
echo "   ✅ Responsive istatistik kartları"
echo ""

