#!/bin/bash
# Sunucu IP Kontrol Scripti
# Kullanım: bash deploy/SUNUCU_IP_KONTROL.sh

echo "🔍 Sunucu IP Kontrol"
echo "===================="
echo ""

# 1. Sunucu IP Adresleri
echo "📡 [1/6] Sunucu IP Adresleri:"
echo ""

# Ana IP
MAIN_IP=$(hostname -I | awk '{print $1}')
echo "   Ana IP: $MAIN_IP"

# Tüm IP'ler
ALL_IPS=$(hostname -I)
echo "   Tüm IP'ler: $ALL_IPS"

# Beklenen IP
EXPECTED_IP="37.148.208.77"
echo "   Beklenen IP: $EXPECTED_IP"

if [ "$MAIN_IP" = "$EXPECTED_IP" ]; then
    echo "   ✅ IP adresi eşleşiyor!"
else
    echo "   ⚠️  IP adresi eşleşmiyor!"
    echo "   → Kontrol edin: Sunucu IP'si doğru mu?"
fi

# 2. Nginx Dinleme Portları
echo ""
echo "🔌 [2/6] Nginx Dinleme Portları:"
NGINX_PORTS=$(sudo netstat -tlnp 2>/dev/null | grep nginx | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -u)
if [ -n "$NGINX_PORTS" ]; then
    echo "   Nginx dinlenen portlar: $NGINX_PORTS"
    if echo "$NGINX_PORTS" | grep -q "80"; then
        echo "   ✅ Port 80 açık (HTTP)"
    else
        echo "   ❌ Port 80 kapalı!"
    fi
else
    echo "   ❌ Nginx çalışmıyor veya port bulunamadı"
fi

# 3. Gunicorn Dinleme
echo ""
echo "🔌 [3/6] Gunicorn Dinleme:"
GUNICORN_PORT=$(sudo netstat -tlnp 2>/dev/null | grep gunicorn | grep LISTEN | awk '{print $4}' | cut -d: -f2 | head -1)
if [ -n "$GUNICORN_PORT" ]; then
    echo "   Gunicorn port: $GUNICORN_PORT"
    if [ "$GUNICORN_PORT" = "8000" ]; then
        echo "   ✅ Port 8000 açık (Gunicorn)"
    else
        echo "   ⚠️  Gunicorn farklı portta: $GUNICORN_PORT"
    fi
else
    echo "   ❌ Gunicorn çalışmıyor veya port bulunamadı"
fi

# 4. Nginx Config Kontrolü
echo ""
echo "⚙️  [4/6] Nginx Config Kontrolü:"
if [ -f "/etc/nginx/sites-available/kutahyaaricilarbirligi" ]; then
    echo "   ✅ Config dosyası var"
    
    # Server name kontrolü
    SERVER_NAMES=$(grep -i "server_name" /etc/nginx/sites-available/kutahyaaricilarbirligi | head -1)
    echo "   Server names: $SERVER_NAMES"
    
    # Listen kontrolü
    LISTEN_LINE=$(grep -i "listen" /etc/nginx/sites-available/kutahyaaricilarbirligi | head -1)
    echo "   Listen: $LISTEN_LINE"
    
    # IP binding kontrolü
    if grep -q "listen.*0.0.0.0\|listen.*$MAIN_IP" /etc/nginx/sites-available/kutahyaaricilarbirligi; then
        echo "   ✅ Tüm IP'lerde dinliyor"
    elif grep -q "listen 80" /etc/nginx/sites-available/kutahyaaricilarbirligi; then
        echo "   ✅ Port 80'de dinliyor (varsayılan: tüm IP'ler)"
    else
        echo "   ⚠️  IP binding kontrol edilmeli"
    fi
else
    echo "   ❌ Config dosyası bulunamadı!"
fi

# 5. Site Test (Local IP)
echo ""
echo "🌐 [5/6] Site Test (Local IP):"
LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://$MAIN_IP 2>/dev/null || echo "000")
if [ "$LOCAL_TEST" = "200" ]; then
    echo "   ✅ Local IP erişilebilir (HTTP $LOCAL_TEST)"
    echo "   → Test: http://$MAIN_IP"
else
    echo "   ❌ Local IP erişilemiyor (HTTP $LOCAL_TEST)"
fi

# 6. Site Test (Beklenen IP)
echo ""
echo "🌐 [6/6] Site Test (Beklenen IP):"
EXPECTED_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://$EXPECTED_IP 2>/dev/null || echo "000")
if [ "$EXPECTED_TEST" = "200" ]; then
    echo "   ✅ Beklenen IP erişilebilir (HTTP $EXPECTED_TEST)"
    echo "   → Test: http://$EXPECTED_IP"
else
    echo "   ❌ Beklenen IP erişilemiyor (HTTP $EXPECTED_TEST)"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

if [ "$MAIN_IP" = "$EXPECTED_IP" ]; then
    echo "✅ Sunucu IP'si doğru: $MAIN_IP"
else
    echo "⚠️  Sunucu IP'si farklı!"
    echo "   Mevcut IP: $MAIN_IP"
    echo "   Beklenen IP: $EXPECTED_IP"
    echo "   → Kontrol edin: Sunucu IP'si doğru mu?"
fi

if [ "$LOCAL_TEST" = "200" ] || [ "$EXPECTED_TEST" = "200" ]; then
    echo "✅ Site IP üzerinden erişilebilir!"
    echo ""
    echo "🌐 Test Adresleri:"
    if [ "$LOCAL_TEST" = "200" ]; then
        echo "   - http://$MAIN_IP"
    fi
    if [ "$EXPECTED_TEST" = "200" ]; then
        echo "   - http://$EXPECTED_IP"
    fi
else
    echo "❌ Site IP üzerinden erişilemiyor!"
    echo "   → Nginx ve Gunicorn'u kontrol edin"
fi

echo ""
echo "💡 Yapılacaklar:"
echo "   1. IP adresi doğru mu kontrol edin"
echo "   2. Nginx config'de 'listen 80' olduğundan emin olun"
echo "   3. Firewall'da port 80 açık mı kontrol edin"
echo "   4. DNS ayarlarını yapın (Natro panel)"
echo ""

