# 🔧 Nginx Config'den SSL Satırlarını Kaldırma

## ⚠️ Sorun

Nginx config dosyasında SSL sertifika yolları var ama dosyalar yok.

## 🔧 Çözüm: SSL Satırlarını Kaldır veya Yorum Satırı Yap

### ADIM 1: Config Dosyasını Düzenle

```bash
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

### ADIM 2: SSL Satırlarını Bul ve Kaldır

Şu satırları bulun:
```nginx
ssl_certificate /etc/letsencrypt/live/kutahyaaricilarbirligi.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/kutahyaaricilarbirligi.com/privkey.pem;
```

**VEYA** şu satırları:
```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
```

Bu satırları **yorum satırı yapın** (başına `#` ekleyin) veya **silin**.

### ADIM 3: HTTPS Bloğunu Kaldır veya Yorum Satırı Yap

HTTPS bloğunu (443 portu) bulun ve yorum satırı yapın:

```nginx
# HTTPS Server - SSL sertifikası yüklendikten sonra aktif edin
# server {
#     listen 443 ssl http2;
#     ...
# }
```

Sadece HTTP bloğu (80 portu) kalmalı.

### ADIM 4: Örnek Config (Sadece HTTP)

Config dosyası şu şekilde olmalı:

```nginx
# HTTP Server
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
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
    }
}
```

### ADIM 5: Test ve Reload

```bash
# Config test
sudo nginx -t

# Başarılıysa reload
sudo systemctl reload nginx

# Durumu kontrol et
sudo systemctl status nginx
```

## 🚀 Hızlı Çözüm: Config Dosyasını Yeniden Oluştur

Eğer config dosyası çok karışıksa, temiz bir HTTP-only config oluşturun:

```bash
# Mevcut config'i yedekle
sudo cp /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-available/kutahyaaricilarbirligi.backup

# Yeni config oluştur
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Yukarıdaki HTTP-only config'i yapıştırın.

Sonra:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

