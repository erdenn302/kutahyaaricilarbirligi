#!/bin/bash
# Site Tam Kontrol - Tüm Sorunları Kontrol Et
# Kullanım: bash deploy/SITE_TAM_KONTROL.sh

echo "🔍 Site Tam Kontrol - Tüm Sorunları Kontrol Et"
echo "==============================================="
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. DEBUG ve ALLOWED_HOSTS kontrolü
echo "1️⃣  [1/8] DEBUG ve ALLOWED_HOSTS Kontrolü:"
echo ""

if [ -f ".env" ]; then
    DEBUG_VALUE=$(grep "^DEBUG=" .env | cut -d= -f2)
    ALLOWED_HOSTS_VALUE=$(grep "^ALLOWED_HOSTS=" .env | cut -d= -f2)
    
    echo "   DEBUG: $DEBUG_VALUE"
    if [ "$DEBUG_VALUE" = "False" ]; then
        echo "   ✅ DEBUG = False (production için doğru)"
    else
        echo "   ⚠️  DEBUG = $DEBUG_VALUE (production için False olmalı)"
    fi
    
    echo "   ALLOWED_HOSTS: $ALLOWED_HOSTS_VALUE"
    if echo "$ALLOWED_HOSTS_VALUE" | grep -q "37.148.208.77\|kutahyaaricilarbirligi.com"; then
        echo "   ✅ ALLOWED_HOSTS doğru yapılandırılmış"
    else
        echo "   ❌ ALLOWED_HOSTS'de IP veya domain yok!"
        echo "   → .env dosyasını güncelleyin: ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77"
    fi
else
    echo "   ❌ .env dosyası bulunamadı!"
    echo "   → .env dosyası oluşturun"
fi

# Django settings kontrolü
DJANGO_CHECK=$(python manage.py check 2>&1)
if echo "$DJANGO_CHECK" | grep -q "System check identified no issues"; then
    echo "   ✅ Django check başarılı"
else
    echo "   ⚠️  Django check uyarıları:"
    echo "$DJANGO_CHECK" | grep -i "warning\|error" | head -5
fi

# 2. Static dosyalar kontrolü
echo ""
echo "2️⃣  [2/8] Static Dosyalar Kontrolü:"
echo ""

if [ -d "staticfiles" ]; then
    STATIC_COUNT=$(find staticfiles -type f 2>/dev/null | wc -l)
    echo "   ✅ staticfiles klasörü var ($STATIC_COUNT dosya)"
    
    if [ "$STATIC_COUNT" -gt 0 ]; then
        echo "   ✅ Static dosyalar toplanmış"
        
        # CSS/JS kontrolü
        CSS_COUNT=$(find staticfiles -name "*.css" 2>/dev/null | wc -l)
        JS_COUNT=$(find staticfiles -name "*.js" 2>/dev/null | wc -l)
        echo "      CSS dosyaları: $CSS_COUNT"
        echo "      JS dosyaları: $JS_COUNT"
    else
        echo "   ⚠️  staticfiles klasörü boş!"
        echo "   → python manage.py collectstatic --noinput çalıştırın"
    fi
    
    # İzinler
    STATIC_OWNER=$(stat -c "%U:%G" staticfiles 2>/dev/null || echo "unknown")
    echo "      Sahip: $STATIC_OWNER (www-data:www-data olmalı)"
    
    if [ "$STATIC_OWNER" != "www-data:www-data" ]; then
        echo "   ⚠️  İzinler yanlış → sudo chown -R www-data:www-data staticfiles"
    fi
else
    echo "   ❌ staticfiles klasörü yok!"
    echo "   → python manage.py collectstatic --noinput çalıştırın"
fi

# 3. Migration / Veritabanı kontrolü
echo ""
echo "3️⃣  [3/8] Migration / Veritabanı Kontrolü:"
echo ""

# Database bağlantısı
DB_TEST=$(python manage.py migrate --check 2>&1)
if echo "$DB_TEST" | grep -q "No migrations to apply\|All migrations have been applied"; then
    echo "   ✅ Database bağlantısı başarılı"
    echo "   ✅ Tüm migrations uygulanmış"
elif echo "$DB_TEST" | grep -qi "error\|failed"; then
    echo "   ❌ Database hatası:"
    echo "$DB_TEST" | grep -i "error\|failed" | head -3
    echo "   → bash deploy/VERITABANI_HIZLI_COZUM.sh çalıştırın (SQLite'a geç)"
else
    echo "   ⚠️  Migration durumu belirsiz"
    echo "$DB_TEST" | head -5
fi

# Database dosyası kontrolü (SQLite)
if [ -f "db.sqlite3" ]; then
    DB_SIZE=$(du -h db.sqlite3 | cut -f1)
    echo "   ✅ db.sqlite3 var (Boyut: $DB_SIZE)"
    
    # İzinler
    DB_OWNER=$(stat -c "%U:%G" db.sqlite3 2>/dev/null || echo "unknown")
    if [ "$DB_OWNER" != "www-data:www-data" ] && [ "$DB_OWNER" != "root:root" ]; then
        echo "   ⚠️  İzinler kontrol edilmeli: $DB_OWNER"
    fi
fi

# 4. WSGI / Gunicorn yapılandırma kontrolü
echo ""
echo "4️⃣  [4/8] WSGI / Gunicorn Yapılandırma Kontrolü:"
echo ""

# WSGI import test
WSGI_TEST=$(python -c "
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kutahyaaricilarbirligi.settings')
try:
    from kutahyaaricilarbirligi.wsgi import application
    print('OK')
except Exception as e:
    print(f'ERROR: {e}')
" 2>&1)

if [ "$WSGI_TEST" = "OK" ]; then
    echo "   ✅ WSGI application import başarılı"
else
    echo "   ❌ WSGI import hatası:"
    echo "   $WSGI_TEST"
fi

# Gunicorn service dosyası
if [ -f "/etc/systemd/system/gunicorn.service" ]; then
    echo "   ✅ Gunicorn service dosyası var"
    
    # EnvironmentFile kontrolü
    if grep -q "EnvironmentFile\|Environment=" /etc/systemd/system/gunicorn.service; then
        echo "   ✅ Environment variables yapılandırılmış"
    else
        echo "   ⚠️  Environment variables yapılandırılmamış"
    fi
    
    # WorkingDirectory kontrolü
    if grep -q "WorkingDirectory=/var/www/kutahyaaricilarbirligi" /etc/systemd/system/gunicorn.service; then
        echo "   ✅ WorkingDirectory doğru"
    else
        echo "   ⚠️  WorkingDirectory kontrol edilmeli"
    fi
else
    echo "   ❌ Gunicorn service dosyası yok!"
    echo "   → sudo cp deploy/gunicorn.service /etc/systemd/system/"
fi

# Gunicorn durumu
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn 2>/dev/null || echo "inactive")
if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "   ✅ Gunicorn çalışıyor"
else
    echo "   ❌ Gunicorn çalışmıyor!"
    echo "   → sudo systemctl status gunicorn"
fi

# 5. Sunucu logları kontrolü
echo ""
echo "5️⃣  [5/8] Sunucu Logları Kontrolü:"
echo ""

# Gunicorn log
echo "   📋 Gunicorn log (son 10 satır):"
GUNICORN_LOG=$(sudo journalctl -u gunicorn -n 10 --no-pager 2>&1 | tail -5)
if [ -n "$GUNICORN_LOG" ]; then
    echo "$GUNICORN_LOG" | grep -i "error\|failed\|exception" || echo "      ✅ Hata yok"
else
    echo "      ⚠️  Log bulunamadı"
fi

# Nginx log
echo ""
echo "   📋 Nginx error log (son 10 satır):"
if [ -f "/var/log/nginx/error.log" ]; then
    NGINX_ERROR=$(sudo tail -10 /var/log/nginx/error.log 2>/dev/null | grep -i "error\|failed" || echo "      ✅ Hata yok")
    echo "$NGINX_ERROR"
else
    echo "      ⚠️  Error log bulunamadı"
fi

# Django log
echo ""
echo "   📋 Django log (son 5 satır):"
if [ -f "logs/django.log" ]; then
    DJANGO_LOG=$(tail -5 logs/django.log 2>/dev/null | grep -i "error\|exception" || echo "      ✅ Hata yok")
    echo "$DJANGO_LOG"
else
    echo "      ⚠️  Django log bulunamadı"
fi

# 6. Python paketleri kontrolü
echo ""
echo "6️⃣  [6/8] Python Paketleri Kontrolü:"
echo ""

REQUIRED_PACKAGES=("Django" "gunicorn" "whitenoise" "Pillow" "django-ckeditor" "python-dotenv")

for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
    if pip list | grep -qi "$PACKAGE"; then
        VERSION=$(pip list | grep -i "$PACKAGE" | awk '{print $2}')
        echo "   ✅ $PACKAGE: $VERSION"
    else
        echo "   ❌ $PACKAGE: Yüklü değil!"
        echo "      → pip install $PACKAGE"
    fi
done

# requirements.txt kontrolü
if [ -f "requirements.txt" ]; then
    echo ""
    echo "   ✅ requirements.txt var"
    MISSING=$(pip install -r requirements.txt --dry-run 2>&1 | grep -i "would install" || echo "")
    if [ -z "$MISSING" ]; then
        echo "   ✅ Tüm paketler yüklü"
    else
        echo "   ⚠️  Eksik paketler olabilir"
    fi
else
    echo "   ⚠️  requirements.txt bulunamadı"
fi

# 7. Dosya izinleri kontrolü
echo ""
echo "7️⃣  [7/8] Dosya İzinleri Kontrolü:"
echo ""

# Proje dizini
PROJECT_PERM=$(stat -c "%a" /var/www/kutahyaaricilarbirligi 2>/dev/null || echo "000")
echo "   Proje dizini: $PROJECT_PERM (755 olmalı)"

# .env dosyası
if [ -f ".env" ]; then
    ENV_PERM=$(stat -c "%a" .env 2>/dev/null || echo "000")
    echo "   .env dosyası: $ENV_PERM (644 veya 600 olmalı)"
fi

# staticfiles
if [ -d "staticfiles" ]; then
    STATIC_PERM=$(stat -c "%a" staticfiles 2>/dev/null || echo "000")
    STATIC_OWNER=$(stat -c "%U:%G" staticfiles 2>/dev/null || echo "unknown")
    echo "   staticfiles: $STATIC_PERM, sahip: $STATIC_OWNER (www-data:www-data olmalı)"
fi

# media
if [ -d "media" ]; then
    MEDIA_PERM=$(stat -c "%a" media 2>/dev/null || echo "000")
    MEDIA_OWNER=$(stat -c "%U:%G" media 2>/dev/null || echo "unknown")
    echo "   media: $MEDIA_PERM, sahip: $MEDIA_OWNER (www-data:www-data olmalı)"
fi

# 8. Gunicorn socket / port kontrolü
echo ""
echo "8️⃣  [8/8] Gunicorn Socket / Port Kontrolü:"
echo ""

# Port 8000 kontrolü
PORT_8000=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " || echo "")
if [ -n "$PORT_8000" ]; then
    echo "   ✅ Port 8000 açık"
    echo "      $PORT_8000"
    
    # Hangi process dinliyor?
    PROCESS=$(echo "$PORT_8000" | awk '{print $7}' | cut -d/ -f2)
    echo "      Process: $PROCESS (gunicorn olmalı)"
    
    if echo "$PROCESS" | grep -qi "gunicorn"; then
        echo "   ✅ Gunicorn port 8000'de dinliyor"
    else
        echo "   ⚠️  Port 8000'de farklı bir process var"
    fi
else
    echo "   ❌ Port 8000 kapalı!"
    echo "   → Gunicorn çalışmıyor olabilir"
fi

# Nginx proxy_pass kontrolü
if [ -f "/etc/nginx/sites-available/kutahyaaricilarbirligi" ]; then
    PROXY_PASS=$(grep "proxy_pass" /etc/nginx/sites-available/kutahyaaricilarbirligi | grep -v "#" | head -1)
    if echo "$PROXY_PASS" | grep -q "127.0.0.1:8000"; then
        echo "   ✅ Nginx proxy_pass doğru (127.0.0.1:8000)"
    else
        echo "   ⚠️  Nginx proxy_pass kontrol edilmeli"
        echo "      $PROXY_PASS"
    fi
fi

# Local test
LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
if [ "$LOCAL_TEST" = "200" ]; then
    echo "   ✅ Gunicorn local test başarılı (HTTP $LOCAL_TEST)"
else
    echo "   ❌ Gunicorn local test başarısız (HTTP $LOCAL_TEST)"
fi

# Site test
SITE_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
if [ "$SITE_TEST" = "200" ]; then
    echo "   ✅ Site erişilebilir (HTTP $SITE_TEST)"
elif [ "$SITE_TEST" = "502" ]; then
    echo "   ❌ 502 Bad Gateway (Gunicorn bağlantı sorunu)"
elif [ "$SITE_TEST" = "400" ]; then
    echo "   ❌ 400 Bad Request (ALLOWED_HOSTS sorunu)"
elif [ "$SITE_TEST" = "301" ]; then
    echo "   ⚠️  301 Redirect (SSL yönlendirme)"
else
    echo "   ⚠️  Site yanıt: HTTP $SITE_TEST"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet ve Öneriler:"
echo ""

ISSUES=0

# Kontrol 1
if [ "$DEBUG_VALUE" != "False" ] || [ ! -f ".env" ]; then
    echo "❌ 1. DEBUG/ALLOWED_HOSTS sorunu var"
    ISSUES=$((ISSUES+1))
fi

# Kontrol 2
if [ ! -d "staticfiles" ] || [ "$STATIC_COUNT" -eq 0 ]; then
    echo "❌ 2. Static dosyalar eksik"
    ISSUES=$((ISSUES+1))
fi

# Kontrol 3
if echo "$DB_TEST" | grep -qi "error\|failed"; then
    echo "❌ 3. Database sorunu var"
    ISSUES=$((ISSUES+1))
fi

# Kontrol 4
if [ "$GUNICORN_STATUS" != "active" ] || [ "$WSGI_TEST" != "OK" ]; then
    echo "❌ 4. Gunicorn/WSGI sorunu var"
    ISSUES=$((ISSUES+1))
fi

# Kontrol 5
if [ -z "$PORT_8000" ] || [ "$LOCAL_TEST" != "200" ]; then
    echo "❌ 8. Port/socket sorunu var"
    ISSUES=$((ISSUES+1))
fi

if [ "$ISSUES" -eq 0 ]; then
    echo "✅ Tüm kontroller başarılı!"
    echo ""
    echo "🌐 Site çalışıyor: http://37.148.208.77"
else
    echo ""
    echo "⚠️  $ISSUES sorun bulundu - yukarıdaki önerilere bakın"
fi

echo ""
