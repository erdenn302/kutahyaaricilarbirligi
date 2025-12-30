#!/bin/bash
# Site Görünmüyor - Hızlı Çözüm
# Kullanım: bash deploy/SITE_GORUNMUYOR_HIZLI_COZUM.sh

echo "🔍 Site Görünmüyor - Sorun Giderme"
echo "===================================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Servis Durumları
echo "📊 [1/8] Servis Durumları:"
NGINX_STATUS=$(sudo systemctl is-active nginx 2>/dev/null || echo "inactive")
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn 2>/dev/null || echo "inactive")

if [ "$NGINX_STATUS" = "active" ]; then
    echo "✅ Nginx: Çalışıyor"
else
    echo "❌ Nginx: Çalışmıyor → Başlatılıyor..."
    sudo systemctl start nginx
fi

if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "✅ Gunicorn: Çalışıyor"
else
    echo "❌ Gunicorn: Çalışmıyor → Başlatılıyor..."
    sudo systemctl start gunicorn
fi

# 2. Static Files
echo ""
echo "📁 [2/8] Static Files Kontrolü:"
if [ ! -d "staticfiles" ] || [ -z "$(ls -A staticfiles 2>/dev/null)" ]; then
    echo "⚠️  Static files eksik → Toplanıyor..."
    python manage.py collectstatic --noinput
    sudo chown -R www-data:www-data staticfiles
    echo "✅ Static files toplandı!"
else
    echo "✅ Static files: Var"
fi

# 3. Media Klasörü
echo ""
echo "📁 [3/8] Media Klasörü:"
if [ ! -d "media" ]; then
    mkdir -p media
    sudo chown -R www-data:www-data media
    echo "✅ Media klasörü oluşturuldu!"
else
    echo "✅ Media klasörü: Var"
fi

# 4. Database Kontrolü
echo ""
echo "🗄️  [4/8] Database Kontrolü:"
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "✅ Database: Bağlantı başarılı"
else
    echo "⚠️  Database: Sorun var → SQLite'a geçiliyor..."
    bash deploy/VERITABANI_HIZLI_COZUM.sh
fi

# 5. Site Test (Local)
echo ""
echo "🌐 [5/8] Site Test (Local):"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Local site: Çalışıyor (HTTP $HTTP_CODE)"
    
    # İçerik kontrolü
    CONTENT=$(curl -s http://localhost | head -20)
    if echo "$CONTENT" | grep -q "html\|DOCTYPE"; then
        echo "✅ Site içeriği: HTML dönüyor"
    else
        echo "⚠️  Site içeriği: HTML dönmüyor olabilir"
    fi
else
    echo "❌ Local site: Çalışmıyor (HTTP $HTTP_CODE)"
fi

# 6. Domain Test
echo ""
echo "🌐 [6/8] Domain Test:"
DOMAIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://kutahyaaricilarbirligi.com 2>/dev/null || echo "000")
if [ "$DOMAIN_CODE" = "200" ]; then
    echo "✅ Domain: Çalışıyor (HTTP $DOMAIN_CODE)"
else
    echo "⚠️  Domain: Sorun olabilir (HTTP $DOMAIN_CODE)"
    echo "   → DNS kontrolü gerekebilir"
fi

# 7. IP Test
echo ""
echo "🌐 [7/8] IP Test:"
IP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
if [ "$IP_CODE" = "200" ]; then
    echo "✅ IP: Çalışıyor (HTTP $IP_CODE)"
    echo "   → IP ile erişim: http://37.148.208.77"
else
    echo "❌ IP: Çalışmıyor (HTTP $IP_CODE)"
fi

# 8. Firewall Kontrolü
echo ""
echo "🔥 [8/8] Firewall Kontrolü:"
UFW_STATUS=$(sudo ufw status 2>/dev/null | grep -i "Status" || echo "Status: unknown")
echo "$UFW_STATUS"

if echo "$UFW_STATUS" | grep -qi "active"; then
    UFW_80=$(sudo ufw status 2>/dev/null | grep "80/tcp" || echo "")
    if [ -z "$UFW_80" ]; then
        echo "⚠️  Port 80: Firewall'da kapalı → Açılıyor..."
        sudo ufw allow 80/tcp
        sudo ufw reload
        echo "✅ Port 80 açıldı!"
    else
        echo "✅ Port 80: Firewall'da açık"
    fi
fi

# Özet ve Öneriler
echo ""
echo "======================================"
echo "📋 Özet ve Öneriler:"
echo ""

if [ "$HTTP_CODE" = "200" ] && [ "$IP_CODE" = "200" ]; then
    echo "✅ Sunucu çalışıyor!"
    echo ""
    echo "🌐 Test Adresleri:"
    echo "   1. IP ile: http://37.148.208.77"
    echo "   2. Domain ile: http://kutahyaaricilarbirligi.com"
    echo ""
    echo "💡 Eğer tarayıcıda görünmüyorsa:"
    echo "   1. Hard Refresh: Ctrl + F5"
    echo "   2. Cache temizle"
    echo "   3. Farklı tarayıcı dene"
    echo "   4. Incognito/Private mode dene"
    echo "   5. DNS kontrolü yap (nslookup kutahyaaricilarbirligi.com)"
else
    echo "⚠️  Sunucu sorunları var!"
    echo "   → Logları kontrol edin:"
    echo "     sudo tail -50 /var/log/nginx/error.log"
    echo "     sudo journalctl -u gunicorn -n 50"
fi

echo ""

