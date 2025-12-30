#!/bin/bash
# Nginx Hızlı Düzeltme - HTTP Only
# Kullanım: bash deploy/NGINX_HIZLI_DUZELTME.sh

echo "🔧 Nginx Hızlı Düzeltme"
echo "======================="
echo ""

# HTTP-only config oluştur
echo "📝 HTTP-only config oluşturuluyor..."

sudo tee /etc/nginx/sites-available/kutahyaaricilarbirligi > /dev/null << 'EOF'
# HTTP Server - SSL sertifikası yüklendikten sonra HTTPS bloğu eklenecek
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
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
    }
}
EOF

echo "✅ Config dosyası oluşturuldu!"

# Symlink kontrolü
echo ""
echo "🔗 Symlink kontrol ediliyor..."
if [ ! -L /etc/nginx/sites-enabled/kutahyaaricilarbirligi ]; then
    sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/
    echo "✅ Symlink oluşturuldu!"
else
    echo "✅ Symlink zaten var."
fi

# Config test
echo ""
echo "⚙️  Config test ediliyor..."
if sudo nginx -t; then
    echo "✅ Config doğru!"
    
    # Nginx'i başlat
    echo ""
    echo "🚀 Nginx başlatılıyor..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    sleep 2
    
    # Durum kontrolü
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ Nginx başarıyla başlatıldı!"
    else
        echo "❌ Nginx başlatılamadı!"
        echo "   → Logları kontrol edin: sudo tail -50 /var/log/nginx/error.log"
    fi
else
    echo "❌ Config hatası var!"
    echo "   → Manuel kontrol: sudo nginx -t"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""
echo "🌐 Site test:"
echo "   curl -I http://localhost"
echo "   curl -I http://kutahyaaricilarbirligi.com"
echo ""

