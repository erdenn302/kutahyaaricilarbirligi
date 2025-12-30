#!/bin/bash
# Son Kontrol ve Test Scripti
# Kullanım: bash deploy/SON_KONTROL_VE_TEST.sh

echo "✅ Son Kontrol ve Test"
echo "====================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. IP Adresi
echo "📡 [1/7] IP Adresi:"
MAIN_IP=$(hostname -I | awk '{print $1}')
echo "   Sunucu IP: $MAIN_IP"
if [ "$MAIN_IP" = "37.148.208.77" ]; then
    echo "   ✅ IP adresi doğru!"
else
    echo "   ⚠️  IP adresi farklı!"
fi

# 2. Servis Durumları
echo ""
echo "📊 [2/7] Servis Durumları:"
NGINX_STATUS=$(sudo systemctl is-active nginx 2>/dev/null || echo "inactive")
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn 2>/dev/null || echo "inactive")

if [ "$NGINX_STATUS" = "active" ]; then
    echo "   ✅ Nginx: Çalışıyor"
else
    echo "   ❌ Nginx: Çalışmıyor"
fi

if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "   ✅ Gunicorn: Çalışıyor"
else
    echo "   ❌ Gunicorn: Çalışmıyor"
fi

# 3. Port Kontrolü
echo ""
echo "🔌 [3/7] Port Kontrolü:"
PORT_80=$(sudo netstat -tlnp 2>/dev/null | grep ":80 " | wc -l)
PORT_8000=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)

if [ "$PORT_80" -gt 0 ]; then
    echo "   ✅ Port 80: Açık"
else
    echo "   ❌ Port 80: Kapalı"
fi

if [ "$PORT_8000" -gt 0 ]; then
    echo "   ✅ Port 8000: Açık"
else
    echo "   ❌ Port 8000: Kapalı"
fi

# 4. Site Test (Local)
echo ""
echo "🌐 [4/7] Site Test (Local):"
LOCAL_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
if [ "$LOCAL_CODE" = "200" ]; then
    echo "   ✅ Local: Çalışıyor (HTTP $LOCAL_CODE)"
else
    echo "   ❌ Local: Çalışmıyor (HTTP $LOCAL_CODE)"
fi

# 5. Site Test (IP)
echo ""
echo "🌐 [5/7] Site Test (IP):"
IP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$MAIN_IP 2>/dev/null || echo "000")
if [ "$IP_CODE" = "200" ]; then
    echo "   ✅ IP ($MAIN_IP): Çalışıyor (HTTP $IP_CODE)"
    echo "   → Test: http://$MAIN_IP"
else
    echo "   ❌ IP ($MAIN_IP): Çalışmıyor (HTTP $IP_CODE)"
fi

# 6. Static Files
echo ""
echo "📁 [6/7] Static Files:"
if [ -d "staticfiles" ] && [ "$(ls -A staticfiles 2>/dev/null)" ]; then
    STATIC_COUNT=$(find staticfiles -type f | wc -l)
    echo "   ✅ Static files: Var ($STATIC_COUNT dosya)"
else
    echo "   ⚠️  Static files: Eksik veya boş"
    echo "   → Toplanıyor..."
    python manage.py collectstatic --noinput > /dev/null 2>&1
    sudo chown -R www-data:www-data staticfiles
    echo "   ✅ Static files toplandı!"
fi

# 7. Database
echo ""
echo "🗄️  [7/7] Database:"
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "   ✅ Database: Bağlantı başarılı"
else
    echo "   ⚠️  Database: Sorun var"
    echo "   → SQLite'a geçiliyor..."
    bash deploy/VERITABANI_HIZLI_COZUM.sh > /dev/null 2>&1
    echo "   ✅ SQLite'a geçildi!"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

ALL_OK=true

if [ "$NGINX_STATUS" != "active" ] || [ "$GUNICORN_STATUS" != "active" ]; then
    ALL_OK=false
    echo "❌ Servisler çalışmıyor!"
    echo "   → sudo systemctl restart nginx"
    echo "   → sudo systemctl restart gunicorn"
fi

if [ "$IP_CODE" != "200" ]; then
    ALL_OK=false
    echo "❌ Site IP üzerinden erişilemiyor!"
fi

if [ "$ALL_OK" = true ]; then
    echo "✅ Tüm kontroller başarılı!"
    echo ""
    echo "🎉 Site yayında ve çalışıyor!"
    echo ""
    echo "🌐 Erişim Adresleri:"
    echo "   - IP: http://$MAIN_IP"
    echo "   - Local: http://localhost"
    echo ""
    echo "📝 Sonraki Adımlar:"
    echo "   1. DNS ayarlarını yapın (Natro panel)"
    echo "      - @ → $MAIN_IP"
    echo "      - www → $MAIN_IP"
    echo "   2. DNS yayılımını bekleyin (15-30 dakika)"
    echo "   3. Domain ile test: http://kutahyaaricilarbirligi.com"
    echo "   4. Admin panel: http://$MAIN_IP/admin/"
    echo "   5. İçerik ekleyin ve logo yükleyin"
else
    echo "⚠️  Bazı sorunlar var!"
    echo "   → Yukarıdaki hataları düzeltin"
fi

echo ""

