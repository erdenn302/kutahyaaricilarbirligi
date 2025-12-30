#!/bin/bash
# DNS Kontrol Scripti
# Kullanım: bash deploy/DNS_KONTROL.sh

echo "🔍 DNS Kontrol"
echo "=============="
echo ""

DOMAIN="kutahyaaricilarbirligi.com"
EXPECTED_IP="37.148.208.77"

echo "🌐 Domain: $DOMAIN"
echo "📍 Beklenen IP: $EXPECTED_IP"
echo ""

# DNS lookup
echo "📡 DNS Lookup:"
if command -v dig &> /dev/null; then
    DNS_RESULT=$(dig +short $DOMAIN)
    echo "   DNS Sonucu: $DNS_RESULT"
    
    if [ "$DNS_RESULT" = "$EXPECTED_IP" ]; then
        echo "   ✅ DNS doğru yönlendirilmiş!"
    else
        echo "   ❌ DNS yanlış yönlendirilmiş!"
        echo "   → Natro DNS ayarlarını kontrol edin"
    fi
elif command -v nslookup &> /dev/null; then
    DNS_RESULT=$(nslookup $DOMAIN | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
    echo "   DNS Sonucu: $DNS_RESULT"
    
    if [ "$DNS_RESULT" = "$EXPECTED_IP" ]; then
        echo "   ✅ DNS doğru yönlendirilmiş!"
    else
        echo "   ❌ DNS yanlış yönlendirilmiş!"
        echo "   → Natro DNS ayarlarını kontrol edin"
    fi
else
    echo "   ⚠️  dig veya nslookup bulunamadı"
fi

# www subdomain kontrolü
echo ""
echo "🌐 www Subdomain Kontrolü:"
if command -v dig &> /dev/null; then
    WWW_RESULT=$(dig +short www.$DOMAIN)
    echo "   DNS Sonucu: $WWW_RESULT"
    
    if [ "$WWW_RESULT" = "$EXPECTED_IP" ]; then
        echo "   ✅ www DNS doğru yönlendirilmiş!"
    else
        echo "   ❌ www DNS yanlış yönlendirilmiş!"
    fi
elif command -v nslookup &> /dev/null; then
    WWW_RESULT=$(nslookup www.$DOMAIN | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
    echo "   DNS Sonucu: $WWW_RESULT"
    
    if [ "$WWW_RESULT" = "$EXPECTED_IP" ]; then
        echo "   ✅ www DNS doğru yönlendirilmiş!"
    else
        echo "   ❌ www DNS yanlış yönlendirilmiş!"
    fi
fi

# Site test
echo ""
echo "🌐 Site Test:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Domain erişilebilir (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    echo "   ❌ Domain erişilemiyor"
else
    echo "   ⚠️  Domain yanıt veriyor ama hata var (HTTP $HTTP_CODE)"
fi

# IP test
echo ""
echo "🌐 IP Test:"
IP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$EXPECTED_IP 2>/dev/null || echo "000")
if [ "$IP_CODE" = "200" ]; then
    echo "   ✅ IP erişilebilir (HTTP $IP_CODE)"
    echo "   → IP ile test: http://$EXPECTED_IP"
else
    echo "   ❌ IP erişilemiyor (HTTP $IP_CODE)"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

if [ "$DNS_RESULT" = "$EXPECTED_IP" ] && [ "$IP_CODE" = "200" ]; then
    echo "✅ DNS doğru yönlendirilmiş ve site çalışıyor!"
    echo ""
    echo "🌐 Site Adresleri:"
    echo "   - http://$DOMAIN"
    echo "   - http://www.$DOMAIN"
    echo "   - http://$EXPECTED_IP"
elif [ "$DNS_RESULT" != "$EXPECTED_IP" ] && [ "$IP_CODE" = "200" ]; then
    echo "⚠️  DNS henüz yayılmamış ama IP ile erişilebilir!"
    echo ""
    echo "💡 Yapılacaklar:"
    echo "   1. Natro DNS ayarlarını kontrol edin"
    echo "   2. A kayıtlarını ekleyin:"
    echo "      - @ → $EXPECTED_IP"
    echo "      - www → $EXPECTED_IP"
    echo "   3. DNS yayılımını bekleyin (5-30 dakika)"
    echo "   4. Şimdilik IP ile test: http://$EXPECTED_IP"
else
    echo "❌ Sorunlar var!"
    echo ""
    echo "💡 Kontrol edin:"
    echo "   1. DNS ayarları (Natro panel)"
    echo "   2. Sunucu durumu (nginx, gunicorn)"
    echo "   3. Firewall ayarları"
fi

echo ""

