# 🚀 Kütahya Arı Yetiştiricileri Birliği - Detaylı Deployment

## 📋 Sunucu Bilgileri

- **Sunucu IP**: 37.148.208.77/32
- **Domain**: kutahyaaricilarbirligi.com
- **SSL Sertifikası**: Mevcut (yüklenecek)

## 🔧 Adım Adım Deployment

### 1. Sunucuya Bağlanma

```bash
ssh root@37.148.208.77
# veya
ssh kullanici@37.148.208.77
```

### 2. Sistem Güncellemesi

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 3. Gerekli Paketlerin Kurulumu

```bash
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    postgresql \
    postgresql-contrib \
    nginx \
    git \
    build-essential \
    libpq-dev
```

### 4. Projeyi Sunucuya Yükleme

#### Yöntem 1: GitHub'dan (Önerilen)

```bash
cd /var/www
sudo git clone https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
sudo chown -R $USER:$USER kutahyaaricilarbirligi
cd kutahyaaricilarbirligi
```

#### Yöntem 2: Manuel Yükleme

```bash
# Proje dosyalarını /var/www/kutahyaaricilarbirligi dizinine yükleyin
cd /var/www
sudo mkdir kutahyaaricilarbirligi
sudo chown -R $USER:$USER kutahyaaricilarbirligi
# Dosyaları buraya kopyalayın (FTP, SCP, vs.)
```

### 5. Virtual Environment ve Bağımlılıklar

```bash
cd /var/www/kutahyaaricilarbirligi
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 6. PostgreSQL Veritabanı Kurulumu

```bash
# PostgreSQL'e bağlan
sudo -u postgres psql

# PostgreSQL içinde:
CREATE DATABASE kutahyaaricilarbirligi;
CREATE USER kutahyaaricilarbirligi WITH PASSWORD 'GÜVENLİ_ŞİFRE_BURAYA';
ALTER ROLE kutahyaaricilarbirligi SET client_encoding TO 'utf8';
ALTER ROLE kutahyaaricilarbirligi SET default_transaction_isolation TO 'read committed';
ALTER ROLE kutahyaaricilarbirligi SET timezone TO 'Europe/Istanbul';
GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;
\q
```

### 7. Environment Variables (.env dosyası)

```bash
cd /var/www/kutahyaaricilarbirligi
nano .env
```

`.env` dosyası içeriği:

```env
DJANGO_SECRET_KEY=GÜVENLİ_SECRET_KEY_BURAYA
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GÜVENLİ_ŞİFRE_BURAYA
DB_HOST=localhost
DB_PORT=5432
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

**Secret Key oluşturma:**
```bash
source venv/bin/activate
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 8. Django Ayarları

`kutahyaaricilarbirligi/settings.py` dosyasını kontrol edin. Environment variables otomatik olarak okunacaktır.

### 9. Django Migrations ve Superuser

```bash
source venv/bin/activate
export DJANGO_SETTINGS_MODULE=kutahyaaricilarbirligi.settings
python manage.py migrate
python manage.py createsuperuser
```

### 10. İlk Verileri Yükleme (Opsiyonel)

```bash
python manage.py create_initial_data
```

### 11. Static Files Toplama

```bash
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
```

### 12. SSL Sertifikası Yükleme

Mevcut SSL sertifikanızı sunucuya yükleyin:

```bash
# Sertifika dosyalarını yükleyin (FTP, SCP, vs.)
# Örnek: /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
# Örnek: /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Dosya izinlerini ayarlayın
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

**Not**: Sertifika dosyalarınızın gerçek yolunu `deploy/nginx.conf` dosyasında güncelleyin!

### 13. Nginx Yapılandırması

```bash
# Nginx config dosyasını kopyala
sudo cp deploy/nginx.conf /etc/nginx/sites-available/kutahyaaricilarbirligi

# SSL sertifika yollarını düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
# ssl_certificate ve ssl_certificate_key satırlarını gerçek yollarınızla değiştirin

# Symlink oluştur
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# Default site'ı devre dışı bırak (opsiyonel)
sudo rm /etc/nginx/sites-enabled/default

# Nginx config'i test et
sudo nginx -t

# Nginx'i yeniden başlat
sudo systemctl reload nginx
```

### 14. Gunicorn Service

```bash
# Service dosyasını kopyala
sudo cp deploy/gunicorn.service /etc/systemd/system/

# Service dosyasını düzenle (gerekirse)
sudo nano /etc/systemd/system/gunicorn.service
# WorkingDirectory ve ExecStart yollarını kontrol edin

# Systemd'yi yeniden yükle
sudo systemctl daemon-reload

# Gunicorn'u başlat ve otomatik başlatmayı etkinleştir
sudo systemctl enable gunicorn
sudo systemctl start gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

### 15. Log Dizini Oluşturma

```bash
mkdir -p /var/www/kutahyaaricilarbirligi/logs
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi/logs
```

### 16. Firewall Ayarları

```bash
# UFW firewall kurulumu (eğer yoksa)
sudo apt-get install ufw

# Gerekli portları aç
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Durumu kontrol et
sudo ufw status
```

### 17. Test ve Kontrol

```bash
# Gunicorn logları
sudo journalctl -u gunicorn -f

# Nginx logları
sudo tail -f /var/log/nginx/kutahyaaricilarbirligi_error.log
sudo tail -f /var/log/nginx/kutahyaaricilarbirligi_access.log

# Siteyi test et
curl -I https://kutahyaaricilarbirligi.com
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

## 🆘 Sorun Giderme

### Site açılmıyor

```bash
# Gunicorn durumu
sudo systemctl status gunicorn

# Nginx durumu
sudo systemctl status nginx

# Nginx config test
sudo nginx -t

# Port kontrolü
sudo netstat -tlnp | grep :8000
sudo netstat -tlnp | grep :443
```

### 502 Bad Gateway

```bash
# Gunicorn loglarına bak
sudo journalctl -u gunicorn -n 50

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn
```

### SSL Sertifika Hatası

```bash
# Sertifika dosyalarının varlığını kontrol et
ls -la /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Nginx config'teki yolları kontrol et
sudo nginx -t
```

### Static Files Görünmüyor

```bash
# Static files'ı tekrar topla
python manage.py collectstatic --noinput

# İzinleri kontrol et
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi/staticfiles
```

## 📝 Önemli Notlar

1. **SSL Sertifikası**: Mevcut sertifikanızın yolunu `nginx.conf` dosyasında mutlaka güncelleyin
2. **Secret Key**: Production'da mutlaka güçlü bir secret key kullanın
3. **Database Şifresi**: Güçlü bir şifre kullanın
4. **Backup**: Düzenli backup alın
5. **Log Monitoring**: Log dosyalarını düzenli kontrol edin

## ✅ Deployment Kontrol Listesi

- [ ] Tüm paketler kuruldu
- [ ] PostgreSQL veritabanı oluşturuldu
- [ ] .env dosyası oluşturuldu ve dolduruldu
- [ ] Django migrations çalıştırıldı
- [ ] Superuser oluşturuldu
- [ ] Static files toplandı
- [ ] SSL sertifikası yüklendi ve yolları güncellendi
- [ ] Nginx yapılandırıldı ve test edildi
- [ ] Gunicorn service başlatıldı
- [ ] Firewall ayarlandı
- [ ] Site test edildi

---

**Başarılar!** 🎉


