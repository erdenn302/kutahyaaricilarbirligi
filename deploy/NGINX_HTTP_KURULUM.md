# 🌐 Nginx HTTP-Only Kurulumu (SSL Olmadan)

## 🎯 Amaç

SSL sertifikası henüz yüklenmediği için önce HTTP (port 80) ile siteyi çalıştıralım. SSL sertifikası yüklendikten sonra HTTPS ekleyeceğiz.

## 🚀 Hızlı Kurulum

```bash
cd /var/www/kutahyaaricilarbirligi

# HTTP-only config dosyasını kopyala
sudo cp deploy/nginx_http_only.conf /etc/nginx/sites-available/kutahyaaricilarbirligi

# Nginx config test
sudo nginx -t

# Başarılıysa reload
sudo systemctl reload nginx

# Durumu kontrol et
sudo systemctl status nginx
```

## ✅ Kontrol

```bash
# Nginx durumu
sudo systemctl status nginx

# Port kontrolü
sudo netstat -tlnp | grep :80

# Siteyi test et
curl -I http://kutahyaaricilarbirligi.com
```

## 🔒 SSL Sertifikası Yüklendikten Sonra

SSL sertifikası yükledikten sonra HTTPS bloğunu ekleyin:

```bash
# Config dosyasını düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

HTTPS bloğunu ekleyin (dosyanın sonuna):

```nginx
# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;

    # SSL Sertifikaları
    ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
    ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
    
    # SSL Ayarları
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Logs
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    # Client max body size
    client_max_body_size 10M;
    
    # Static files
    location /static/ {
        alias /var/www/kutahyaaricilarbirligi/staticfiles/;
        expires 30d;
    }
    
    # Media files
    location /media/ {
        alias /var/www/kutahyaaricilarbirligi/media/;
        expires 7d;
    }
    
    # Django uygulaması
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
```

Ve HTTP bloğuna HTTPS'e yönlendirme ekleyin:

```nginx
# HTTP Server - HTTPS'e yönlendirme
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
    # Tüm trafiği HTTPS'e yönlendir
    location / {
        return 301 https://$host$request_uri;
    }
}
```

Sonra:
```bash
sudo nginx -t
sudo systemctl reload nginx
```


