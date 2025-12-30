#!/bin/bash
# SSL Sertifika Kurulum - Adım Adım
# Kullanım: bash deploy/SSL_KURULUM_ADIM_ADIM.sh

echo "🔐 SSL Sertifika Kurulum"
echo "========================"
echo ""

# 1. Sertifika dosyalarını kontrol et
echo "📋 [1/6] Sertifika dosyaları kontrol ediliyor..."
echo ""

CERT_PATH="/etc/ssl/certs/kutahyaaricilarbirligi.com.crt"
KEY_PATH="/etc/ssl/private/kutahyaaricilarbirligi.com.key"

if [ -f "$CERT_PATH" ]; then
    echo "   ✅ Sertifika dosyası var: $CERT_PATH"
    ls -lh "$CERT_PATH"
else
    echo "   ❌ Sertifika dosyası bulunamadı: $CERT_PATH"
    echo ""
    echo "   💡 Sertifika dosyasını yüklemeniz gerekiyor:"
    echo "      1. Sertifika dosyasını sunucuya yükleyin (SCP, FTP, vs.)"
    echo "      2. Dosyayı şu konuma taşıyın: $CERT_PATH"
    echo "      3. İzinleri ayarlayın: sudo chmod 644 $CERT_PATH"
    echo ""
    exit 1
fi

if [ -f "$KEY_PATH" ]; then
    echo "   ✅ Private key dosyası var: $KEY_PATH"
    ls -lh "$KEY_PATH"
else
    echo "   ❌ Private key dosyası bulunamadı: $KEY_PATH"
    echo ""
    echo "   💡 Private key dosyasını yüklemeniz gerekiyor:"
    echo "      1. Private key dosyasını sunucuya yükleyin (SCP, FTP, vs.)"
    echo "      2. Dosyayı şu konuma taşıyın: $KEY_PATH"
    echo "      3. İzinleri ayarlayın: sudo chmod 600 $KEY_PATH"
    echo ""
    exit 1
fi

# 2. İzinleri kontrol et ve ayarla
echo ""
echo "🔒 [2/6] Dosya izinleri kontrol ediliyor..."

CERT_PERM=$(stat -c "%a" "$CERT_PATH" 2>/dev/null || echo "000")
KEY_PERM=$(stat -c "%a" "$KEY_PATH" 2>/dev/null || echo "000")

if [ "$CERT_PERM" != "644" ]; then
    echo "   ⚠️  Sertifika izinleri yanlış ($CERT_PERM) → Düzeltiliyor..."
    sudo chmod 644 "$CERT_PATH"
    sudo chown root:root "$CERT_PATH"
    echo "   ✅ Sertifika izinleri düzeltildi (644)"
else
    echo "   ✅ Sertifika izinleri doğru (644)"
fi

if [ "$KEY_PERM" != "600" ]; then
    echo "   ⚠️  Private key izinleri yanlış ($KEY_PERM) → Düzeltiliyor..."
    sudo chmod 600 "$KEY_PATH"
    sudo chown root:root "$KEY_PATH"
    echo "   ✅ Private key izinleri düzeltildi (600)"
else
    echo "   ✅ Private key izinleri doğru (600)"
fi

# 3. Sertifika bilgilerini göster
echo ""
echo "📜 [3/6] Sertifika bilgileri:"
echo ""
sudo openssl x509 -in "$CERT_PATH" -noout -subject -dates 2>/dev/null || echo "   ⚠️  Sertifika bilgileri okunamadı"

# 4. Nginx SSL config oluştur
echo ""
echo "⚙️  [4/6] Nginx SSL config oluşturuluyor..."

sudo tee /etc/nginx/sites-available/kutahyaaricilarbirligi > /dev/null << EOF
# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com 37.148.208.77;
    
    return 301 https://\$host\$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com 37.148.208.77;
    
    # SSL Sertifikaları
    ssl_certificate $CERT_PATH;
    ssl_certificate_key $KEY_PATH;
    
    # SSL Ayarları
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Logs
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    # Client max body size
    client_max_body_size 10M;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Static files
    location /static/ {
        alias /var/www/kutahyaaricilarbirligi/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Media files
    location /media/ {
        alias /var/www/kutahyaaricilarbirligi/media/;
        expires 7d;
        add_header Cache-Control "public";
    }
    
    # Django uygulaması
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo "   ✅ Nginx SSL config oluşturuldu!"

# 5. Nginx config test
echo ""
echo "⚙️  [5/6] Nginx config test ediliyor..."
if sudo nginx -t; then
    echo "   ✅ Nginx config doğru!"
else
    echo "   ❌ Nginx config hatası!"
    exit 1
fi

# 6. Nginx restart
echo ""
echo "🔄 [6/6] Nginx yeniden başlatılıyor..."
sudo systemctl stop nginx
sleep 1
sudo systemctl start nginx
sleep 2

if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx başlatıldı!"
else
    echo "   ❌ Nginx başlatılamadı!"
    sudo tail -20 /var/log/nginx/error.log
    exit 1
fi

# Test
echo ""
echo "🌐 SSL Test..."
sleep 2

# HTTP test (301 redirect olmalı)
HTTP_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   HTTP (37.148.208.77): $HTTP_TEST (301 redirect olmalı)"

# HTTPS test
HTTPS_TEST=$(curl -s -o /dev/null -w "%{http_code}" -k https://37.148.208.77 2>/dev/null || echo "000")
echo "   HTTPS (37.148.208.77): $HTTPS_TEST"

if [ "$HTTPS_TEST" = "200" ]; then
    echo ""
    echo "   ✅ HTTPS çalışıyor!"
    echo "   → Test: https://37.148.208.77"
elif [ "$HTTPS_TEST" = "000" ]; then
    echo ""
    echo "   ⚠️  HTTPS yanıt vermiyor"
    echo "   → Sertifika ve key dosyalarını kontrol edin"
else
    echo ""
    echo "   ⚠️  HTTPS yanıt veriyor (HTTP $HTTPS_TEST)"
fi

# Django settings güncelleme
echo ""
echo "🐍 Django settings güncelleniyor..."
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# settings.py'de SSL ayarlarını aktif et
if grep -q "SECURE_SSL_REDIRECT = False" kutahyaaricilarbirligi/settings.py; then
    sed -i 's/SECURE_SSL_REDIRECT = False/SECURE_SSL_REDIRECT = True/' kutahyaaricilarbirligi/settings.py
    sed -i 's/SESSION_COOKIE_SECURE = False/SESSION_COOKIE_SECURE = True/' kutahyaaricilarbirligi/settings.py
    sed -i 's/CSRF_COOKIE_SECURE = False/CSRF_COOKIE_SECURE = True/' kutahyaaricilarbirligi/settings.py
    echo "   ✅ Django SSL ayarları aktif edildi!"
    
    # Gunicorn restart
    sudo systemctl restart gunicorn
    sleep 3
    echo "   ✅ Gunicorn yeniden başlatıldı!"
else
    echo "   ⚠️  settings.py'de SSL ayarları zaten aktif veya farklı formatta"
fi

echo ""
echo "======================================"
echo "✅ SSL kurulum tamamlandı!"
echo ""
echo "🌐 Test Adresleri:"
echo "   - HTTP: http://37.148.208.77 (301 redirect olmalı)"
echo "   - HTTPS: https://37.148.208.77"
echo "   - Domain: https://kutahyaaricilarbirligi.com (DNS yayılımı sonrası)"
echo ""

