# 🌐 Site Görüntüleme Sorun Giderme

## 🔍 Adım Adım Kontrol

### 1. Servislerin Durumunu Kontrol Et

```bash
# Nginx durumu
sudo systemctl status nginx

# Gunicorn durumu
sudo systemctl status gunicorn

# Her ikisi de "active (running)" olmalı
```

### 2. Port Kontrolü

```bash
# Port 80 (HTTP) açık mı?
sudo netstat -tlnp | grep :80

# Port 8000 (Gunicorn) açık mı?
sudo netstat -tlnp | grep :8000
```

### 3. Site Test (Sunucuda)

```bash
# Local test
curl -I http://localhost

# Domain test
curl -I http://kutahyaaricilarbirligi.com

# IP test
curl -I http://37.148.208.77
```

### 4. Nginx Log Kontrolü

```bash
# Hata logları
sudo tail -50 /var/log/nginx/error.log

# Erişim logları
sudo tail -50 /var/log/nginx/access.log
```

### 5. Gunicorn Log Kontrolü

```bash
# Gunicorn logları
sudo journalctl -u gunicorn -n 50 --no-pager
```

### 6. Nginx Config Test

```bash
# Nginx config doğru mu?
sudo nginx -t
```

### 7. Firewall Kontrolü

```bash
# Firewall durumu
sudo ufw status

# Port 80 açık mı?
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 8. Django Test

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# Django check
python manage.py check

# Test server (manuel)
python manage.py runserver 0.0.0.0:8000
```

## ❌ Yaygın Sorunlar ve Çözümleri

### Sorun 1: Nginx çalışmıyor

```bash
# Nginx'i başlat
sudo systemctl start nginx

# Nginx'i enable et (otomatik başlatma)
sudo systemctl enable nginx
```

### Sorun 2: Gunicorn çalışmıyor

```bash
# Gunicorn'u başlat
sudo systemctl start gunicorn

# Gunicorn'u enable et
sudo systemctl enable gunicorn

# Logları kontrol et
sudo journalctl -u gunicorn -n 50
```

### Sorun 3: Nginx config hatası

```bash
# Config test
sudo nginx -t

# Hata varsa düzelt
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi

# Sonra reload
sudo systemctl reload nginx
```

### Sorun 4: Port 80 kapalı

```bash
# Firewall'u kontrol et
sudo ufw status

# Port 80'i aç
sudo ufw allow 80/tcp
sudo ufw reload
```

### Sorun 5: Database hatası

```bash
# SQLite kullan (hızlı çözüm)
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
bash deploy/VERITABANI_HIZLI_COZUM.sh
```

### Sorun 6: Static files yok

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
```

## 🚀 Hızlı Yeniden Başlatma

```bash
# Tüm servisleri yeniden başlat
sudo systemctl restart nginx
sudo systemctl restart gunicorn

# Durumları kontrol et
sudo systemctl status nginx
sudo systemctl status gunicorn
```

## 📋 Tam Kontrol Scripti

```bash
bash deploy/SITE_TAM_KONTROL.sh
```

