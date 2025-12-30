# 🚀 Kütahya Arı Yetiştiricileri Birliği - Production Deployment

Bu dokümantasyon, projeyi Ubuntu sunucuda production ortamına deploy etmek için adım adım talimatları içerir.

## 📋 Gereksinimler

- Ubuntu 20.04 veya üzeri
- Python 3.8+
- PostgreSQL
- Nginx
- SSL Sertifikası (Let's Encrypt veya kendi sertifikanız)
- Domain: www.kutahyaaricilarbirligi.com

## 🔧 Kurulum Adımları

### 1. Sunucu Hazırlığı

```bash
# Sistem güncellemesi
sudo apt-get update
sudo apt-get upgrade -y

# Gerekli paketler
sudo apt-get install -y python3 python3-pip python3-venv postgresql postgresql-contrib nginx certbot python3-certbot-nginx git
```

### 2. Projeyi Sunucuya Yükleme

#### Yöntem 1: GitHub'dan Clone

```bash
cd /var/www
sudo git clone https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
sudo chown -R $USER:$USER kutahyaaricilarbirligi
cd kutahyaaricilarbirligi
```

#### Yöntem 2: Manuel Yükleme

```bash
# Projeyi zip olarak yükleyip açın
cd /var/www
sudo mkdir kutahyaaricilarbirligi
sudo chown -R $USER:$USER kutahyaaricilarbirligi
# Proje dosyalarını buraya kopyalayın
```

### 3. Virtual Environment ve Bağımlılıklar

```bash
cd /var/www/kutahyaaricilarbirligi
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Environment Variables

`.env` dosyası oluşturun:

```bash
nano .env
```

İçeriği:

```env
DJANGO_SECRET_KEY=GÜVENLİ_SECRET_KEY_BURAYA
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GÜVENLİ_ŞİFRE_BURAYA
DB_HOST=localhost
DB_PORT=5432
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com
```

Secret key oluşturmak için:
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 5. PostgreSQL Veritabanı

```bash
sudo -u postgres psql
```

PostgreSQL içinde:

```sql
CREATE DATABASE kutahyaaricilarbirligi;
CREATE USER kutahyaaricilarbirligi WITH PASSWORD 'GÜVENLİ_ŞİFRE_BURAYA';
ALTER ROLE kutahyaaricilarbirligi SET client_encoding TO 'utf8';
ALTER ROLE kutahyaaricilarbirligi SET default_transaction_isolation TO 'read committed';
ALTER ROLE kutahyaaricilarbirligi SET timezone TO 'Europe/Istanbul';
GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;
\q
```

### 6. Django Ayarları

`kutahyaaricilarbirligi/settings.py` dosyasını production için güncelleyin veya `settings_production.py` kullanın:

```bash
# .env dosyasından environment variables okuyacak şekilde ayarlayın
export DJANGO_SETTINGS_MODULE=kutahyaaricilarbirligi.settings_production
```

### 7. Migrations ve Superuser

```bash
source venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
```

### 8. Static Files

```bash
python manage.py collectstatic --noinput
```

### 9. Gunicorn Service

`deploy/gunicorn.service` dosyasını `/etc/systemd/system/` içine kopyalayın:

```bash
sudo cp deploy/gunicorn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn
sudo systemctl status gunicorn
```

### 10. Nginx Yapılandırması

```bash
# Nginx config dosyasını kopyala
sudo cp deploy/nginx.conf /etc/nginx/sites-available/kutahyaaricilarbirligi

# Symlink oluştur
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# Test et
sudo nginx -t

# Nginx'i yeniden başlat
sudo systemctl reload nginx
```

### 11. SSL Sertifikası (Let's Encrypt)

```bash
# Let's Encrypt ile SSL sertifikası al
sudo certbot --nginx -d kutahyaaricilarbirligi.com -d www.kutahyaaricilarbirligi.com

# Otomatik yenileme testi
sudo certbot renew --dry-run
```

### 12. Firewall Ayarları

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
```

## 🔄 Güncelleme İşlemi

Projeyi güncellerken:

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
git pull  # veya yeni dosyaları kopyalayın
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart gunicorn
sudo systemctl reload nginx
```

## 📝 Log Kontrolü

```bash
# Gunicorn logları
sudo journalctl -u gunicorn -f

# Nginx logları
sudo tail -f /var/log/nginx/kutahyaaricilarbirligi_error.log
sudo tail -f /var/log/nginx/kutahyaaricilarbirligi_access.log

# Django logları
tail -f /var/www/kutahyaaricilarbirligi/logs/django.log
```

## 🔒 Güvenlik Kontrol Listesi

- [ ] DEBUG=False
- [ ] SECRET_KEY environment variable'da
- [ ] SSL sertifikası aktif
- [ ] Firewall yapılandırıldı
- [ ] Database şifreleri güvenli
- [ ] Admin şifresi güçlü
- [ ] Regular backups yapılıyor
- [ ] Log dosyaları kontrol ediliyor

## 🆘 Sorun Giderme

### Site açılmıyor
```bash
sudo systemctl status gunicorn
sudo systemctl status nginx
sudo nginx -t
```

### 502 Bad Gateway
- Gunicorn çalışıyor mu kontrol edin
- Port 8000 açık mı kontrol edin
- Nginx config dosyasını kontrol edin

### Static files görünmüyor
```bash
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi/staticfiles
```

## 📞 Destek

Sorun yaşarsanız log dosyalarını kontrol edin ve hata mesajlarını kaydedin.


