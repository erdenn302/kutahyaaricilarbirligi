#!/bin/bash
# Site Tam Kontrol Scripti
# Kullanım: bash deploy/SITE_TAM_KONTROL.sh

echo "🔍 Site Tam Kontrol"
echo "==================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Servis Durumları
echo "📊 [1/10] Servis Durumları:"
echo ""

NGINX_STATUS=$(sudo systemctl is-active nginx 2>/dev/null || echo "inactive")
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn 2>/dev/null || echo "inactive")

if [ "$NGINX_STATUS" = "active" ]; then
    echo "✅ Nginx: Çalışıyor"
else
    echo "❌ Nginx: Çalışmıyor"
    echo "   → Başlatmak için: sudo systemctl start nginx"
fi

if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "✅ Gunicorn: Çalışıyor"
else
    echo "❌ Gunicorn: Çalışmıyor"
    echo "   → Başlatmak için: sudo systemctl start gunicorn"
fi

# 2. Port Kontrolü
echo ""
echo "🔌 [2/10] Port Kontrolü:"
PORT_80=$(sudo netstat -tlnp 2>/dev/null | grep ":80 " | wc -l)
PORT_8000=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)

if [ "$PORT_80" -gt 0 ]; then
    echo "✅ Port 80: Açık"
else
    echo "❌ Port 80: Kapalı"
fi

if [ "$PORT_8000" -gt 0 ]; then
    echo "✅ Port 8000: Açık"
else
    echo "❌ Port 8000: Kapalı"
fi

# 3. Nginx Config Test
echo ""
echo "⚙️  [3/10] Nginx Config Test:"
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Nginx config: Doğru"
else
    echo "❌ Nginx config: Hata var!"
    echo "   → Kontrol için: sudo nginx -t"
fi

# 4. Site Test (Local)
echo ""
echo "🌐 [4/10] Site Test (Local):"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Local site: Çalışıyor (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    echo "❌ Local site: Erişilemiyor (curl hatası)"
else
    echo "⚠️  Local site: Yanıt veriyor ama hata var (HTTP $HTTP_CODE)"
fi

# 5. Domain Test
echo ""
echo "🌐 [5/10] Domain Test:"
DOMAIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://kutahyaaricilarbirligi.com 2>/dev/null || echo "000")
if [ "$DOMAIN_CODE" = "200" ]; then
    echo "✅ Domain: Çalışıyor (HTTP $DOMAIN_CODE)"
elif [ "$DOMAIN_CODE" = "000" ]; then
    echo "⚠️  Domain: DNS çözümlenemiyor veya erişilemiyor"
else
    echo "⚠️  Domain: Yanıt veriyor ama hata var (HTTP $DOMAIN_CODE)"
fi

# 6. IP Test
echo ""
echo "🌐 [6/10] IP Test:"
IP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
if [ "$IP_CODE" = "200" ]; then
    echo "✅ IP: Çalışıyor (HTTP $IP_CODE)"
elif [ "$IP_CODE" = "000" ]; then
    echo "❌ IP: Erişilemiyor"
else
    echo "⚠️  IP: Yanıt veriyor ama hata var (HTTP $IP_CODE)"
fi

# 7. Django Check
echo ""
echo "🐍 [7/10] Django Check:"
DJANGO_CHECK=$(python manage.py check 2>&1)
if echo "$DJANGO_CHECK" | grep -q "System check identified no issues"; then
    echo "✅ Django: Sorun yok"
else
    echo "⚠️  Django: Sorunlar var"
    echo "$DJANGO_CHECK" | grep -i "error\|warning" | head -5
fi

# 8. Database Kontrolü
echo ""
echo "🗄️  [8/10] Database Kontrolü:"
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "✅ Database: Bağlantı başarılı"
else
    echo "❌ Database: Bağlantı hatası!"
    echo "$DB_TEST" | grep -i "error\|failed" | head -3
    echo "   → Çözüm: bash deploy/VERITABANI_HIZLI_COZUM.sh"
fi

# 9. Static Files Kontrolü
echo ""
echo "📁 [9/10] Static Files Kontrolü:"
if [ -d "staticfiles" ] && [ "$(ls -A staticfiles 2>/dev/null)" ]; then
    echo "✅ Static files: Var"
else
    echo "⚠️  Static files: Eksik veya boş"
    echo "   → Çözüm: python manage.py collectstatic --noinput"
fi

# 10. Firewall Kontrolü
echo ""
echo "🔥 [10/10] Firewall Kontrolü:"
UFW_STATUS=$(sudo ufw status 2>/dev/null | grep -i "Status" || echo "Status: unknown")
echo "$UFW_STATUS"

if echo "$UFW_STATUS" | grep -qi "active"; then
    UFW_80=$(sudo ufw status | grep "80/tcp" || echo "")
    if [ -n "$UFW_80" ]; then
        echo "✅ Port 80: Firewall'da açık"
    else
        echo "⚠️  Port 80: Firewall'da kapalı olabilir"
        echo "   → Çözüm: sudo ufw allow 80/tcp"
    fi
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet ve Öneriler:"
echo ""

if [ "$NGINX_STATUS" != "active" ]; then
    echo "❌ Nginx çalışmıyor → sudo systemctl start nginx"
fi

if [ "$GUNICORN_STATUS" != "active" ]; then
    echo "❌ Gunicorn çalışmıyor → sudo systemctl start gunicorn"
fi

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "000" ]; then
    echo "⚠️  Site yanıt veriyor ama hata var → Logları kontrol edin"
    echo "   → sudo tail -50 /var/log/nginx/error.log"
fi

if [ "$HTTP_CODE" = "000" ]; then
    echo "❌ Site erişilemiyor → Servisleri kontrol edin"
fi

echo ""
echo "🔧 Hızlı Düzeltme Komutları:"
echo "   sudo systemctl restart nginx"
echo "   sudo systemctl restart gunicorn"
echo "   bash deploy/VERITABANI_HIZLI_COZUM.sh"
echo ""

