# 🔒 Nginx SSL Sertifika Hatası Çözümü

## Sorun

Nginx config dosyasında Let's Encrypt sertifika yolu var ama sertifika dosyası yok.

## 🔧 Çözüm 1: SSL Sertifika Yollarını Güncelle

Nginx config dosyasını düzenleyin:

```bash
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Şu satırları bulun:
```nginx
ssl_certificate /etc/letsencrypt/live/kutahyaaricilarbirligi.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/kutahyaaricilarbirligi.com/privkey.pem;
```

**Mevcut sertifikanızın yollarıyla değiştirin:**
```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
```

**VEYA** eğer sertifika dosyalarınız farklı bir yerdeyse, o yolu kullanın.

## 🔧 Çözüm 2: SSL Olmadan Test (Geçici)

Eğer henüz SSL sertifikası yüklemediyseniz, önce HTTP ile test edin:

```bash
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

HTTPS bloğunu yorum satırı yapın veya silin, sadece HTTP bloğunu bırakın:

```nginx
# HTTP Server (Test için)
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

# HTTPS Server - SSL sertifikası yüklendikten sonra aktif edin
# server {
#     listen 443 ssl http2;
#     ...
# }
```

## 🔍 ADIM 1: Sertifika Dosyalarını Kontrol Et

```bash
# Sertifika dosyalarının varlığını kontrol et
ls -la /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# VEYA farklı bir yerde olabilir, arayın:
sudo find /etc -name "*kutahyaaricilarbirligi*" -type f 2>/dev/null
```

## 🔧 ADIM 2: Config Dosyasını Güncelle

```bash
# Config dosyasını düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

SSL sertifika satırlarını bulun ve mevcut sertifika yollarınızla değiştirin.

## ✅ ADIM 3: Test ve Reload

```bash
# Config test
sudo nginx -t

# Başarılıysa reload
sudo systemctl reload nginx

# Durumu kontrol et
sudo systemctl status nginx
```

## 🚀 Hızlı Çözüm (SSL Olmadan Test)

Eğer SSL sertifikası henüz yoksa, HTTP ile test edin:

```bash
# Config dosyasını düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

HTTPS bloğunu (443 portu) yorum satırı yapın veya silin. Sadece HTTP bloğunu (80 portu) bırakın.

Sonra:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 📝 Örnek Config (SSL Olmadan - Test İçin)

```nginx
# HTTP Server
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    client_max_body_size 10M;
    
    location /static/ {
        alias /var/www/kutahyaaricilarbirligi/staticfiles/;
        expires 30d;
    }
    
    location /media/ {
        alias /var/www/kutahyaaricilarbirligi/media/;
        expires 7d;
    }
    
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

