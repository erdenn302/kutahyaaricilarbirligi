# 🚀 Site Yayına Alma - Adım Adım Rehber

## 📋 Kontrol Listesi

Siteyi yayına almak için şu adımları takip edin:

## ✅ ADIM 1: Sunucuya Bağlan

```bash
ssh root@37.148.208.77
```

## ✅ ADIM 2: Proje Dizinine Git

```bash
cd /var/www/kutahyaaricilarbirligi
```

## ✅ ADIM 3: Git Pull (Güncellemeleri Al)

```bash
source venv/bin/activate
git stash
git pull origin main
```

## ✅ ADIM 4: python-dotenv Kur

```bash
pip install python-dotenv
```

## ✅ ADIM 5: .env Dosyası Oluştur

```bash
# Secret key oluştur ve .env dosyasına yaz
python -c "from django.core.management.utils import get_random_secret_key; print('DJANGO_SECRET_KEY=' + get_random_secret_key())" > .env

# Diğer ayarları ekle
echo "DEBUG=False" >> .env
echo "DB_NAME=kutahyaaricilarbirligi" >> .env
echo "DB_USER=kutahyaaricilarbirligi" >> .env
echo "DB_PASSWORD=GucluSifre_2025!" >> .env
echo "DB_HOST=localhost" >> .env
echo "DB_PORT=5432" >> .env
echo "ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77" >> .env

# İzinleri ayarla
chmod 600 .env
chown root:root .env
```

## ✅ ADIM 6: Static Klasörünü Oluştur

```bash
mkdir -p static/css static/js static/images
chmod -R 755 static
```

## ✅ ADIM 7: Requirements Güncelle

```bash
pip install -r requirements.txt
```

## ✅ ADIM 8: Migrations Çalıştır

```bash
python manage.py migrate
```

## ✅ ADIM 9: Static Files Topla

```bash
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
```

## ✅ ADIM 10: Gunicorn Service Kontrolü

```bash
# Gunicorn service dosyasını kontrol et
sudo nano /etc/systemd/system/gunicorn.service
```

Şu satırın olup olmadığını kontrol edin:
```ini
EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env
```

Yoksa `WorkingDirectory` satırından sonra ekleyin.

Sonra:
```bash
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
```

## ✅ ADIM 11: Nginx Kontrolü

```bash
# Nginx config kontrolü
sudo nginx -t

# Nginx durumu
sudo systemctl status nginx

# Çalışmıyorsa başlat
sudo systemctl start nginx
```

## ✅ ADIM 12: Servisleri Kontrol Et

```bash
# Tüm servislerin durumunu kontrol et
sudo systemctl status nginx
sudo systemctl status gunicorn

# Port kontrolü
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :8000
```

## ✅ ADIM 13: Site Test

```bash
# Local test
curl -I http://localhost

# Domain test
curl -I http://kutahyaaricilarbirligi.com

# IP test
curl -I http://37.148.208.77
```

## ✅ ADIM 14: SECRET_KEY Uyarısı Kontrolü

```bash
python manage.py check
python manage.py collectstatic --noinput
```

Uyarı görünmemeli!

## 🎉 Başarılı!

Eğer tüm adımlar başarılıysa, site yayında!

**Site Adresleri:**
- http://kutahyaaricilarbirligi.com
- http://www.kutahyaaricilarbirligi.com
- http://37.148.208.77

## ❌ Sorun Giderme

### SECRET_KEY uyarısı hala görünüyorsa:

```bash
# .env dosyasını kontrol et
cat .env

# python-dotenv kurulu mu?
pip list | grep python-dotenv

# settings.py'de load_dotenv var mı?
grep -n "load_dotenv" kutahyaaricilarbirligi/settings.py
```

### Gunicorn çalışmıyorsa:

```bash
# Logları kontrol et
sudo journalctl -u gunicorn -n 50

# Manuel başlat
sudo systemctl start gunicorn
```

### Nginx çalışmıyorsa:

```bash
# Logları kontrol et
sudo tail -f /var/log/nginx/error.log

# Config test
sudo nginx -t
```

### Site erişilemiyorsa:

```bash
# Firewall kontrolü
sudo ufw status

# Port kontrolü
sudo netstat -tlnp | grep :80
```

