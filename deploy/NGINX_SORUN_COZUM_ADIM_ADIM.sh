#!/bin/bash
# Nginx Sorun Çözüm - Adım Adım
# Kullanım: bash deploy/NGINX_SORUN_COZUM_ADIM_ADIM.sh

set -e  # Hata durumunda dur

echo "🔧 Nginx Sorun Çözüm - Adım Adım"
echo "================================="
echo ""

# 1. Aktif Nginx config'lerini listele
echo "📋 [1/8] Aktif Nginx config'leri:"
echo ""
sudo ls -la /etc/nginx/sites-enabled/
echo ""

# 2. Varsayılan config'i devre dışı bırak
echo "🗑️  [2/8] Varsayılan config devre dışı bırakılıyor..."
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    sudo rm -f /etc/nginx/sites-enabled/default
    echo "   ✅ Varsayılan config silindi!"
else
    echo "   ✅ Varsayılan config zaten yok"
fi

# 3. Django config dosyasını oluştur
echo ""
echo "📝 [3/8] Django config dosyası oluşturuluyor..."

sudo tee /etc/nginx/sites-available/kutahyaaricilarbirligi > /dev/null << 'EOF'
# Django Application - kutahyaaricilarbirligi.com
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    # Logs
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    # Client max body size
    client_max_body_size 10M;
    
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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo "   ✅ Config dosyası oluşturuldu!"

# 4. Symlink oluştur
echo ""
echo "🔗 [4/8] Symlink oluşturuluyor..."
sudo rm -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi
sudo ln -sf /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/
echo "   ✅ Symlink oluşturuldu!"

# 5. Config test
echo ""
echo "⚙️  [5/8] Config test ediliyor..."
if sudo nginx -t 2>&1 | tee /tmp/nginx_test.log; then
    echo "   ✅ Config doğru!"
else
    echo "   ❌ Config hatası var!"
    cat /tmp/nginx_test.log
    exit 1
fi

# 6. Gunicorn kontrolü
echo ""
echo "🐍 [6/8] Gunicorn kontrolü..."
if sudo systemctl is-active --quiet gunicorn; then
    echo "   ✅ Gunicorn çalışıyor"
else
    echo "   ⚠️  Gunicorn çalışmıyor → Başlatılıyor..."
    sudo systemctl start gunicorn
    sleep 2
    if sudo systemctl is-active --quiet gunicorn; then
        echo "   ✅ Gunicorn başlatıldı!"
    else
        echo "   ❌ Gunicorn başlatılamadı!"
        echo "   → Logları kontrol edin: sudo journalctl -u gunicorn -n 50"
    fi
fi

# 7. Nginx restart (reload değil, tam restart)
echo ""
echo "🔄 [7/8] Nginx yeniden başlatılıyor..."
sudo systemctl stop nginx
sleep 1
sudo systemctl start nginx
sleep 2

if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx başarıyla başlatıldı!"
else
    echo "   ❌ Nginx başlatılamadı!"
    echo "   → Logları kontrol edin: sudo tail -50 /var/log/nginx/error.log"
    exit 1
fi

# 8. Test
echo ""
echo "🌐 [8/8] Site test ediliyor..."
sleep 2

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
echo "   HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    CONTENT=$(curl -s http://37.148.208.77 2>/dev/null | head -30)
    
    if echo "$CONTENT" | grep -qi "Welcome to nginx"; then
        echo "   ❌ Hala Nginx varsayılan sayfası görünüyor!"
        echo ""
        echo "   🔍 Detaylı kontrol:"
        echo "   → Aktif config: sudo nginx -T | grep 'server_name'"
        echo "   → Gunicorn port: sudo netstat -tlnp | grep 8000"
        echo "   → Nginx log: sudo tail -20 /var/log/nginx/error.log"
    elif echo "$CONTENT" | grep -qi "html\|DOCTYPE\|Kütahya\|Arı"; then
        echo "   ✅ Django sitesi çalışıyor!"
        echo "   → Test: http://37.148.208.77"
    else
        echo "   ⚠️  Site yanıt veriyor ama içerik beklenmiyor"
        echo "   → İçerik: $(echo "$CONTENT" | head -5)"
    fi
else
    echo "   ❌ Site erişilemiyor (HTTP $HTTP_CODE)"
fi

# Özet
echo ""
echo "======================================"
echo "📋 Özet:"
echo ""

echo "🔍 Kontrol komutları:"
echo "   1. Aktif config: sudo nginx -T | grep -A 5 'server {'"
echo "   2. Gunicorn: sudo systemctl status gunicorn"
echo "   3. Port 8000: sudo netstat -tlnp | grep 8000"
echo "   4. Nginx log: sudo tail -20 /var/log/nginx/error.log"
echo "   5. Gunicorn log: sudo journalctl -u gunicorn -n 20"
echo ""

