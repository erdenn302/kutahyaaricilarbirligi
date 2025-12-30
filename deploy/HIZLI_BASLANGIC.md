# ⚡ Hızlı Başlangıç - Production Deployment

## 🎯 Sunucu Bilgileri

- **IP**: 37.148.208.77
- **Domain**: kutahyaaricilarbirligi.com
- **SSL**: Mevcut sertifika kullanılacak

## 🚀 Hızlı Deployment (Özet)

### 1. Sunucuya Bağlan
```bash
ssh root@37.148.208.77
```

### 2. Temel Kurulum
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip python3-venv postgresql postgresql-contrib nginx git
```

### 3. Projeyi Yükle
```bash
cd /var/www
git clone https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
cd kutahyaaricilarbirligi
```

### 4. Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 5. Database
```bash
sudo -u postgres psql
# PostgreSQL içinde:
CREATE DATABASE kutahyaaricilarbirligi;
CREATE USER kutahyaaricilarbirligi WITH PASSWORD 'GÜVENLİ_ŞİFRE';
GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;
\q
```

### 6. .env Dosyası
```bash
nano .env
```
İçeriği:
```env
DJANGO_SECRET_KEY=GÜVENLİ_KEY_BURAYA
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GÜVENLİ_ŞİFRE
DB_HOST=localhost
DB_PORT=5432
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

### 7. Django Setup
```bash
source venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
```

### 8. SSL Sertifikası
```bash
# Sertifika dosyalarınızı yükleyin
sudo cp certificate.crt /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo cp private.key /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### 9. Nginx
```bash
sudo cp deploy/nginx.conf /etc/nginx/sites-available/kutahyaaricilarbirligi
# SSL yollarını düzenle:
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 10. Gunicorn
```bash
sudo cp deploy/gunicorn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn
```

### 11. Test
```bash
curl -I https://kutahyaaricilarbirligi.com
```

## 📚 Detaylı Talimatlar

- **Tam deployment**: `deploy/DEPLOYMENT_DETAYLI.md`
- **SSL sertifikası**: `deploy/SSL_SERTIFIKA_TALIMATI.md`

## ✅ Kontrol

- Site: https://kutahyaaricilarbirligi.com
- Admin: https://kutahyaaricilarbirligi.com/admin/

