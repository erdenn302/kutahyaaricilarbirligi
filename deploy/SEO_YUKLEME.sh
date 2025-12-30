#!/bin/bash
# SEO İyileştirmeleri Yükleme Scripti
# Kullanım: bash deploy/SEO_YUKLEME.sh

echo "🔍 SEO İyileştirmeleri Yükleme"
echo "=============================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Git pull
echo "📥 [1/5] Git pull..."
git stash > /dev/null 2>&1 || true
git pull origin main
echo "   ✅ Git pull tamamlandı!"

# 2. Migration (yeni alanlar için)
echo ""
echo "🗄️  [2/5] Veritabanı güncelleniyor..."
python manage.py makemigrations
python manage.py migrate
echo "   ✅ Migration tamamlandı!"

# 3. Static files topla
echo ""
echo "📁 [3/5] Static files toplanıyor..."
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
echo "   ✅ Static files toplandı!"

# 4. Gunicorn restart
echo ""
echo "🔄 [4/5] Gunicorn yeniden başlatılıyor..."
sudo systemctl restart gunicorn
sleep 3

if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn başlatıldı!"
else
    echo "   ❌ Gunicorn başlatılamadı!"
    exit 1
fi

# 5. Nginx reload
echo ""
echo "🔄 [5/5] Nginx yeniden yükleniyor..."
sudo systemctl reload nginx
sleep 2

# Test
echo ""
echo "🌐 SEO Dosyaları Test Ediliyor..."
sleep 2

# Sitemap test
SITEMAP_TEST=$(curl -s -o /dev/null -w "%{http_code}" https://www.kutahyaaricilarbirligi.com/sitemap.xml 2>/dev/null || curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77/sitemap.xml 2>/dev/null || echo "000")
echo "   Sitemap.xml: HTTP $SITEMAP_TEST"

# Robots.txt test
ROBOTS_TEST=$(curl -s -o /dev/null -w "%{http_code}" https://www.kutahyaaricilarbirligi.com/robots.txt 2>/dev/null || curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77/robots.txt 2>/dev/null || echo "000")
echo "   Robots.txt: HTTP $ROBOTS_TEST"

# Site test
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" https://www.kutahyaaricilarbirligi.com 2>/dev/null || curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   Site: HTTP $SITE_TEST"

if [ "$SITEMAP_TEST" = "200" ] && [ "$ROBOTS_TEST" = "200" ] && [ "$SITE_TEST" = "200" ]; then
    echo ""
    echo "   ✅ Tüm SEO dosyaları çalışıyor!"
else
    echo ""
    echo "   ⚠️  Bazı dosyalarda sorun olabilir"
fi

echo ""
echo "======================================"
echo "✅ SEO İyileştirmeleri Yüklendi!"
echo ""
echo "📋 Yapılacaklar:"
echo "   1. Google Search Console'a site ekleyin"
echo "   2. Sitemap'i Google'a gönderin"
echo "   3. GOOGLE_SEO_REHBERI.md dosyasını okuyun"
echo ""
echo "🔗 Önemli Linkler:"
echo "   → Sitemap: https://www.kutahyaaricilarbirligi.com/sitemap.xml"
echo "   → Robots.txt: https://www.kutahyaaricilarbirligi.com/robots.txt"
echo "   → Google Search Console: https://search.google.com/search-console"
echo ""

