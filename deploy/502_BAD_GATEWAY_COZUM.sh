#!/bin/bash
# 502 Bad Gateway Çözümü
# Kullanım: bash deploy/502_BAD_GATEWAY_COZUM.sh

echo "🔧 502 Bad Gateway Çözümü"
echo "========================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Gunicorn durumu
echo "🐍 [1/6] Gunicorn durumu:"
GUNICORN_STATUS=$(sudo systemctl is-active gunicorn 2>/dev/null || echo "inactive")

if [ "$GUNICORN_STATUS" = "active" ]; then
    echo "   ✅ Gunicorn çalışıyor"
else
    echo "   ❌ Gunicorn çalışmıyor → Başlatılıyor..."
    sudo systemctl start gunicorn
    sleep 3
    
    if sudo systemctl is-active --quiet gunicorn; then
        echo "   ✅ Gunicorn başlatıldı!"
    else
        echo "   ❌ Gunicorn başlatılamadı!"
        echo "   → Logları kontrol edin:"
        sudo journalctl -u gunicorn -n 30 --no-pager
        exit 1
    fi
fi

# 2. Port 8000 kontrolü
echo ""
echo "🔌 [2/6] Port 8000 kontrolü:"
PORT_8000=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)

if [ "$PORT_8000" -gt 0 ]; then
    echo "   ✅ Port 8000 açık"
    sudo netstat -tlnp | grep ":8000 "
else
    echo "   ❌ Port 8000 kapalı!"
    echo "   → Gunicorn'u yeniden başlatılıyor..."
    sudo systemctl restart gunicorn
    sleep 3
    
    PORT_8000=$(sudo netstat -tlnp 2>/dev/null | grep ":8000 " | wc -l)
    if [ "$PORT_8000" -gt 0 ]; then
        echo "   ✅ Port 8000 açıldı!"
    else
        echo "   ❌ Port 8000 hala kapalı!"
        echo "   → Manuel kontrol gerekli"
    fi
fi

# 3. Gunicorn log kontrolü
echo ""
echo "📋 [3/6] Gunicorn log kontrolü:"
GUNICORN_ERRORS=$(sudo journalctl -u gunicorn -n 20 --no-pager | grep -i "error\|failed\|exception" || echo "")
if [ -n "$GUNICORN_ERRORS" ]; then
    echo "   ⚠️  Hatalar bulundu:"
    echo "$GUNICORN_ERRORS" | head -5
else
    echo "   ✅ Log'da hata yok"
fi

# 4. Local test (Gunicorn'a direkt)
echo ""
echo "🌐 [4/6] Gunicorn direkt test:"
LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000 2>/dev/null || echo "000")
if [ "$LOCAL_TEST" = "200" ]; then
    echo "   ✅ Gunicorn çalışıyor (HTTP $LOCAL_TEST)"
elif [ "$LOCAL_TEST" = "000" ]; then
    echo "   ❌ Gunicorn yanıt vermiyor!"
    echo "   → Gunicorn'u yeniden başlatılıyor..."
    sudo systemctl restart gunicorn
    sleep 3
else
    echo "   ⚠️  Gunicorn yanıt veriyor ama hata var (HTTP $LOCAL_TEST)"
fi

# 5. Nginx config kontrolü
echo ""
echo "⚙️  [5/6] Nginx config kontrolü:"
if grep -q "proxy_pass http://127.0.0.1:8000" /etc/nginx/sites-available/kutahyaaricilarbirligi; then
    echo "   ✅ Nginx config doğru (proxy_pass var)"
else
    echo "   ❌ Nginx config'de proxy_pass yok!"
    echo "   → Config güncelleniyor..."
    # Config'i güncelle
    sudo sed -i 's|proxy_pass.*|proxy_pass http://127.0.0.1:8000;|' /etc/nginx/sites-available/kutahyaaricilarbirligi
    sudo nginx -t && sudo systemctl reload nginx
    echo "   ✅ Config güncellendi!"
fi

# 6. Nginx restart
echo ""
echo "🔄 [6/6] Nginx yeniden başlatılıyor..."
sudo systemctl reload nginx
sleep 2

# Final test
echo ""
echo "🌐 Final test:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -20)
    if echo "$CONTENT" | grep -qi "Welcome to nginx"; then
        echo "   ⚠️  Hala Nginx varsayılan sayfası (HTTP $HTTP_CODE)"
    elif echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya"; then
        echo "   ✅ Site çalışıyor! (HTTP $HTTP_CODE)"
        echo "   → Test: http://37.148.208.77"
    else
        echo "   ⚠️  Site yanıt veriyor (HTTP $HTTP_CODE)"
    fi
elif [ "$HTTP_CODE" = "502" ]; then
    echo "   ❌ Hala 502 Bad Gateway!"
    echo ""
    echo "   🔍 Detaylı kontrol:"
    echo "   1. Gunicorn: sudo systemctl status gunicorn"
    echo "   2. Port 8000: sudo netstat -tlnp | grep 8000"
    echo "   3. Gunicorn log: sudo journalctl -u gunicorn -n 50"
    echo "   4. Nginx log: sudo tail -50 /var/log/nginx/error.log"
else
    echo "   ❌ Site erişilemiyor (HTTP $HTTP_CODE)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""

