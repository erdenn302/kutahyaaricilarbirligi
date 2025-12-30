# 🔧 Nginx Hata Çözümü

## Sorun Tespiti

Nginx reload hatası alıyorsunuz. Önce hatayı görmemiz gerekiyor.

## 🔍 Adım 1: Hata Detaylarını Görüntüle

```bash
# Nginx durumunu kontrol et
sudo systemctl status nginx.service

# Detaylı logları görüntüle
sudo journalctl -xe

# Nginx config test
sudo nginx -t
```

## 🔧 Adım 2: Nginx Config Test

```bash
# Config dosyasını test et
sudo nginx -t
```

Bu komut size tam olarak hatanın ne olduğunu söyleyecek.

## 🚨 Yaygın Hatalar ve Çözümleri

### Hata 1: SSL Sertifika Dosyası Bulunamadı

```
nginx: [emerg] SSL_CTX_use_certificate_file("/etc/ssl/certs/kutahyaaricilarbirligi.com.crt") failed
```

**Çözüm:**
```bash
# Sertifika dosyasının varlığını kontrol et
ls -la /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Eğer dosyalar yoksa, sertifika yükleme talimatlarını takip edin
# deploy/SSL_SERTIFIKA_ADIM_ADIM.md
```

### Hata 2: Syntax Hatası

```
nginx: [emerg] unexpected "}" in /etc/nginx/sites-available/kutahyaaricilarbirligi:XX
```

**Çözüm:**
```bash
# Config dosyasını kontrol et
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi

# Hatalı satırı düzelt (genellikle eksik veya fazla { } veya ;)
```

### Hata 3: Port Zaten Kullanılıyor

```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

**Çözüm:**
```bash
# Hangi process 80 portunu kullanıyor?
sudo lsof -i :80
sudo lsof -i :443

# Nginx'i durdur ve tekrar başlat
sudo systemctl stop nginx
sudo systemctl start nginx
```

### Hata 4: Directory Bulunamadı

```
nginx: [emerg] open() "/var/www/kutahyaaricilarbirligi/staticfiles/" failed
```

**Çözüm:**
```bash
# Static files klasörünü oluştur
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
python manage.py collectstatic --noinput

# İzinleri ayarla
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi/staticfiles
```

## 🔧 Hızlı Çözüm Adımları

```bash
# 1. Nginx config test
sudo nginx -t

# 2. Hata mesajını oku ve düzelt

# 3. Tekrar test et
sudo nginx -t

# 4. Başarılıysa reload
sudo systemctl reload nginx

# 5. Durumu kontrol et
sudo systemctl status nginx
```

## 📝 Nginx Config Kontrol Listesi

Config dosyasında kontrol edin:

- [ ] SSL sertifika yolları doğru mu?
- [ ] Tüm `;` işaretleri var mı?
- [ ] Tüm `{ }` parantezleri kapalı mı?
- [ ] Static files klasörü var mı?
- [ ] Media files klasörü var mı?
- [ ] Gunicorn portu doğru mu? (127.0.0.1:8000)

## 🆘 Geçici Çözüm: Nginx'i Devre Dışı Bırak

Eğer acil durumdaysanız:

```bash
# Nginx'i durdur
sudo systemctl stop nginx

# Gunicorn'u direkt çalıştır (test için)
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
gunicorn --bind 0.0.0.0:8000 kutahyaaricilarbirligi.wsgi:application

# Tarayıcıdan: http://37.148.208.77:8000
```

## 📋 Nginx Config Örnek (Düzeltilmiş)

Eğer config dosyası bozuksa, şu şablonu kullanın:

```nginx
# HTTP'den HTTPS'e yönlendirme
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;

    # SSL Sertifikaları - YOLLARI GÜNCELLEYİN!
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


