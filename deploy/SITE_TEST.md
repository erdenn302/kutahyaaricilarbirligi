# ✅ Site Test ve Kontrol

## 🎯 Nginx Çalışıyor!

Nginx başarıyla çalışıyor. Şimdi diğer servisleri kontrol edelim.

## 🔍 ADIM 1: Gunicorn Kontrolü

```bash
# Gunicorn durumunu kontrol et
sudo systemctl status gunicorn

# Eğer çalışmıyorsa başlat
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
```

## 🔍 ADIM 2: Port Kontrolü

```bash
# Gunicorn port 8000'de dinliyor mu?
sudo netstat -tlnp | grep 8000

# Nginx port 80'de dinliyor mu?
sudo netstat -tlnp | grep :80
```

## 🔍 ADIM 3: Site Test

```bash
# Localhost'tan test
curl -I http://localhost

# Domain'den test
curl -I http://kutahyaaricilarbirligi.com

# IP'den test
curl -I http://37.148.208.77
```

## 🔍 ADIM 4: Log Kontrolü

```bash
# Nginx error log
sudo tail -20 /var/log/nginx/kutahyaaricilarbirligi_error.log

# Nginx access log
sudo tail -20 /var/log/nginx/kutahyaaricilarbirligi_access.log

# Gunicorn log
sudo journalctl -u gunicorn -n 50
```

## 🆘 Sorun Giderme

### Site açılmıyor

```bash
# Gunicorn çalışıyor mu?
sudo systemctl status gunicorn

# Gunicorn'u başlat
sudo systemctl start gunicorn

# Logları kontrol et
sudo journalctl -u gunicorn -n 50
```

### 502 Bad Gateway

```bash
# Gunicorn loglarına bak
sudo journalctl -u gunicorn -n 50

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn

# Port kontrolü
sudo netstat -tlnp | grep 8000
```

### Static files görünmüyor

```bash
# Static files topla
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
python manage.py collectstatic --noinput

# İzinleri kontrol et
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi/staticfiles
```

## ✅ Başarı Kontrolü

Site çalışıyorsa:
- ✅ http://kutahyaaricilarbirligi.com açılmalı
- ✅ http://37.148.208.77 açılmalı
- ✅ Admin paneli: http://kutahyaaricilarbirligi.com/admin/ çalışmalı

