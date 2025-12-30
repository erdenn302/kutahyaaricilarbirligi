#!/bin/bash
# SSL Sertifika Kontrol Scripti
# Kullanım: bash deploy/SSL_KONTROL.sh

echo "🔐 SSL Sertifika Kontrol"
echo "========================"
echo ""

# 1. Sertifika dosyaları kontrolü
echo "📋 [1/6] Sertifika dosyaları kontrolü:"
echo ""

CERT_PATH="/etc/ssl/certs/kutahyaaricilarbirligi.com.crt"
KEY_PATH="/etc/ssl/private/kutahyaaricilarbirligi.com.key"

if [ -f "$CERT_PATH" ]; then
    echo "   ✅ Sertifika dosyası var: $CERT_PATH"
    ls -lh "$CERT_PATH"
    
    # Sertifika bilgileri
    echo ""
    echo "   📜 Sertifika bilgileri:"
    sudo openssl x509 -in "$CERT_PATH" -noout -subject -dates -issuer 2>/dev/null || echo "   ⚠️  Sertifika bilgileri okunamadı"
else
    echo "   ❌ Sertifika dosyası bulunamadı: $CERT_PATH"
fi

if [ -f "$KEY_PATH" ]; then
    echo ""
    echo "   ✅ Private key dosyası var: $KEY_PATH"
    ls -lh "$KEY_PATH"
    
    # Key bilgileri
    echo ""
    echo "   🔑 Key bilgileri:"
    KEY_BITS=$(sudo openssl rsa -in "$KEY_PATH" -noout -text 2>/dev/null | grep "Private-Key:" | awk '{print $2}')
    if [ -n "$KEY_BITS" ]; then
        echo "      Bit uzunluğu: $KEY_BITS"
    fi
else
    echo ""
    echo "   ❌ Private key dosyası bulunamadı: $KEY_PATH"
fi

# 2. Dosya izinleri kontrolü
echo ""
echo "🔒 [2/6] Dosya izinleri kontrolü:"
if [ -f "$CERT_PATH" ]; then
    CERT_PERM=$(stat -c "%a" "$CERT_PATH" 2>/dev/null || echo "000")
    CERT_OWNER=$(stat -c "%U:%G" "$CERT_PATH" 2>/dev/null || echo "unknown")
    
    if [ "$CERT_PERM" = "644" ]; then
        echo "   ✅ Sertifika izinleri doğru (644)"
    else
        echo "   ⚠️  Sertifika izinleri yanlış ($CERT_PERM) - 644 olmalı"
    fi
    echo "      Sahip: $CERT_OWNER"
fi

if [ -f "$KEY_PATH" ]; then
    KEY_PERM=$(stat -c "%a" "$KEY_PATH" 2>/dev/null || echo "000")
    KEY_OWNER=$(stat -c "%U:%G" "$KEY_PATH" 2>/dev/null || echo "unknown")
    
    if [ "$KEY_PERM" = "600" ]; then
        echo "   ✅ Private key izinleri doğru (600)"
    else
        echo "   ⚠️  Private key izinleri yanlış ($KEY_PERM) - 600 olmalı"
    fi
    echo "      Sahip: $KEY_OWNER"
fi

# 3. Nginx config kontrolü
echo ""
echo "⚙️  [3/6] Nginx config kontrolü:"
if [ -f "/etc/nginx/sites-available/kutahyaaricilarbirligi" ]; then
    if grep -q "ssl_certificate" /etc/nginx/sites-available/kutahyaaricilarbirligi; then
        echo "   ✅ Nginx config'de SSL ayarları var"
        
        # SSL sertifika yolları
        SSL_CERT=$(grep "ssl_certificate " /etc/nginx/sites-available/kutahyaaricilarbirligi | grep -v "#" | head -1 | awk '{print $2}' | tr -d ';')
        SSL_KEY=$(grep "ssl_certificate_key" /etc/nginx/sites-available/kutahyaaricilarbirligi | grep -v "#" | head -1 | awk '{print $2}' | tr -d ';')
        
        echo "      Sertifika yolu: $SSL_CERT"
        echo "      Key yolu: $SSL_KEY"
        
        # Yollar doğru mu?
        if [ "$SSL_CERT" = "$CERT_PATH" ] && [ -f "$CERT_PATH" ]; then
            echo "      ✅ Sertifika yolu doğru"
        else
            echo "      ⚠️  Sertifika yolu kontrol edilmeli"
        fi
        
        if [ "$SSL_KEY" = "$KEY_PATH" ] && [ -f "$KEY_PATH" ]; then
            echo "      ✅ Key yolu doğru"
        else
            echo "      ⚠️  Key yolu kontrol edilmeli"
        fi
    else
        echo "   ❌ Nginx config'de SSL ayarları yok"
    fi
else
    echo "   ❌ Nginx config dosyası bulunamadı"
fi

# 4. Nginx config test
echo ""
echo "⚙️  [4/6] Nginx config test:"
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo "   ✅ Nginx config doğru"
else
    echo "   ❌ Nginx config hatası!"
    sudo nginx -t 2>&1 | tail -5
fi

# 5. Port kontrolü
echo ""
echo "🔌 [5/6] Port kontrolü:"
PORT_443=$(sudo netstat -tlnp 2>/dev/null | grep ":443 " | wc -l)
if [ "$PORT_443" -gt 0 ]; then
    echo "   ✅ Port 443 açık (HTTPS)"
    sudo netstat -tlnp | grep ":443 "
else
    echo "   ❌ Port 443 kapalı"
fi

# 6. SSL bağlantı testi
echo ""
echo "🌐 [6/6] SSL bağlantı testi:"
echo ""

# HTTP test (301 redirect olmalı)
HTTP_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   HTTP (37.148.208.77): $HTTP_TEST"

if [ "$HTTP_TEST" = "301" ] || [ "$HTTP_TEST" = "302" ]; then
    echo "      ✅ HTTP → HTTPS yönlendirme çalışıyor"
elif [ "$HTTP_TEST" = "200" ]; then
    echo "      ⚠️  HTTP yönlendirme yok (hala HTTP'de)"
else
    echo "      ⚠️  HTTP yanıt: $HTTP_TEST"
fi

# HTTPS test
HTTPS_TEST=$(curl -s -o /dev/null -w "%{http_code}" -k https://37.148.208.77 2>/dev/null || echo "000")
echo "   HTTPS (37.148.208.77): $HTTPS_TEST"

if [ "$HTTPS_TEST" = "200" ]; then
    echo "      ✅ HTTPS çalışıyor!"
    
    # SSL sertifika bilgileri
    echo ""
    echo "   📜 SSL Sertifika Detayları:"
    echo | openssl s_client -connect 37.148.208.77:443 -servername 37.148.208.77 2>/dev/null | \
        openssl x509 -noout -subject -dates -issuer 2>/dev/null || echo "      ⚠️  Sertifika bilgileri alınamadı"
elif [ "$HTTPS_TEST" = "000" ]; then
    echo "      ❌ HTTPS yanıt vermiyor"
else
    echo "      ⚠️  HTTPS yanıt: $HTTPS_TEST"
fi

# Domain test (DNS yayılımı varsa)
echo ""
echo "🌐 Domain test (DNS yayılımı varsa):"
DOMAIN_HTTPS=$(curl -s -o /dev/null -w "%{http_code}" -k https://kutahyaaricilarbirligi.com 2>/dev/null || echo "000")
if [ "$DOMAIN_HTTPS" = "200" ]; then
    echo "   ✅ Domain HTTPS çalışıyor: https://kutahyaaricilarbirligi.com"
elif [ "$DOMAIN_HTTPS" = "000" ]; then
    echo "   ⚠️  Domain erişilemiyor (DNS yayılımı bekleniyor olabilir)"
else
    echo "   ⚠️  Domain yanıt: $DOMAIN_HTTPS"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

ALL_OK=true

if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    ALL_OK=false
    echo "❌ Sertifika dosyaları eksik"
    echo "   → CSR oluşturun ve sertifikayı yükleyin"
fi

if ! grep -q "ssl_certificate" /etc/nginx/sites-available/kutahyaaricilarbirligi 2>/dev/null; then
    ALL_OK=false
    echo "❌ Nginx config'de SSL ayarları yok"
    echo "   → bash deploy/SSL_KURULUM_ADIM_ADIM.sh çalıştırın"
fi

if [ "$HTTPS_TEST" != "200" ]; then
    ALL_OK=false
    echo "❌ HTTPS çalışmıyor"
    echo "   → Nginx log: sudo tail -50 /var/log/nginx/error.log"
fi

if [ "$ALL_OK" = true ]; then
    echo "✅ SSL sertifikası kurulu ve çalışıyor!"
    echo ""
    echo "🌐 Test Adresleri:"
    echo "   - HTTPS (IP): https://37.148.208.77"
    if [ "$DOMAIN_HTTPS" = "200" ]; then
        echo "   - HTTPS (Domain): https://kutahyaaricilarbirligi.com"
    fi
else
    echo "⚠️  Bazı sorunlar var - yukarıdaki önerilere bakın"
fi

echo ""

