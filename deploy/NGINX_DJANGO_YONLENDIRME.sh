#!/bin/bash
# Nginx Django Yönlendirme Düzeltme
# Kullanım: bash deploy/NGINX_DJANGO_YONLENDIRME.sh

echo "🔧 Nginx Django Yönlendirme Düzeltme"
echo "===================================="
echo ""

# 1. Varsayılan Nginx config'i kontrol et
echo "📝 [1/5] Varsayılan Nginx config kontrolü:"
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    echo "   ⚠️  Varsayılan config aktif!"
    echo "   → Devre dışı bırakılıyor..."
    sudo rm -f /etc/nginx/sites-enabled/default
    echo "   ✅ Varsayılan config devre dışı bırakıldı!"
else
    echo "   ✅ Varsayılan config zaten devre dışı"
fi

# 2. Django config dosyasını oluştur
echo ""
echo "📝 [2/5] Django config dosyası oluşturuluyor..."

sudo tee /etc/nginx/sites-available/kutahyaaricilarbirligi > /dev/null << 'EOF'
# Django Application - kutahyaaricilarbirligi.com
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com 37.148.208.77;
    
    # Logs
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    # Client max body size (dosya yükleme için)
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
        
        # WebSocket desteği (gerekirse)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeout ayarları
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo "   ✅ Config dosyası oluşturuldu!"

# 3. Symlink oluştur
echo ""
echo "🔗 [3/5] Symlink oluşturuluyor..."
sudo ln -sf /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/
echo "   ✅ Symlink oluşturuldu!"

# 4. Config test
echo ""
echo "⚙️  [4/5] Config test ediliyor..."
if sudo nginx -t; then
    echo "   ✅ Config doğru!"
else
    echo "   ❌ Config hatası var!"
    exit 1
fi

# 5. Nginx reload
echo ""
echo "🔄 [5/5] Nginx yeniden yükleniyor..."
sudo systemctl reload nginx
sleep 2

if sudo systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx başarıyla yeniden yüklendi!"
else
    echo "   ❌ Nginx yeniden yüklenemedi!"
    echo "   → Logları kontrol edin: sudo tail -50 /var/log/nginx/error.log"
    exit 1
fi

# Test
echo ""
echo "🌐 Site test ediliyor..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://37.148.208.77 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    # İçerik kontrolü
    CONTENT=$(curl -s http://37.148.208.77 | head -20)
    if echo "$CONTENT" | grep -qi "nginx"; then
        echo "   ⚠️  Hala Nginx varsayılan sayfası görünüyor!"
        echo "   → Gunicorn çalışıyor mu kontrol edin: sudo systemctl status gunicorn"
    elif echo "$CONTENT" | grep -qi "html\|DOCTYPE"; then
        echo "   ✅ Site çalışıyor! (HTTP $HTTP_CODE)"
        echo "   → Test: http://37.148.208.77"
    else
        echo "   ⚠️  Site yanıt veriyor ama içerik beklenmiyor (HTTP $HTTP_CODE)"
    fi
else
    echo "   ❌ Site erişilemiyor (HTTP $HTTP_CODE)"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""
echo "💡 Kontrol:"
echo "   1. Gunicorn çalışıyor mu: sudo systemctl status gunicorn"
echo "   2. Site test: curl -I http://37.148.208.77"
echo "   3. Tarayıcıda test: http://37.148.208.77"
echo ""

