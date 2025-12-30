# 🐘 PostgreSQL Kurulum ve Yapılandırma

## 📦 Kurulum

```bash
# PostgreSQL kur
sudo apt update
sudo apt install postgresql postgresql-contrib -y

# PostgreSQL servisini başlat
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 🔧 Veritabanı ve Kullanıcı Oluştur

```bash
# PostgreSQL'e bağlan
sudo -u postgres psql
```

PostgreSQL konsolunda:

```sql
-- Veritabanı oluştur
CREATE DATABASE kutahyaaricilarbirligi;

-- Kullanıcı oluştur ve şifre ata
CREATE USER kutahyaaricilarbirligi WITH PASSWORD 'GucluSifre_2025!';

-- İzinleri ver
GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;

-- PostgreSQL'den çık
\q
```

## 🔐 PostgreSQL Kimlik Doğrulama Ayarları

```bash
# pg_hba.conf dosyasını düzenle
sudo nano /etc/postgresql/*/main/pg_hba.conf
```

Şu satırı bulun:
```
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
```

Eğer `md5` yerine `peer` varsa, `md5` olarak değiştirin.

Sonra PostgreSQL'i yeniden başlatın:

```bash
sudo systemctl restart postgresql
```

## ✅ Test Et

```bash
# Kullanıcı ile bağlanmayı test et
psql -U kutahyaaricilarbirligi -d kutahyaaricilarbirligi -h localhost
```

Şifre sorulacak: `GucluSifre_2025!`

Bağlantı başarılıysa:
```sql
\q
```

## 🚀 Django'da Kullan

`.env` dosyasında zaten ayarlı olmalı:

```env
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
```

Sonra:

```bash
python manage.py migrate
```

## ❌ Sorun Giderme

### "password authentication failed" hatası:

1. Şifreyi kontrol edin
2. `pg_hba.conf` dosyasında `md5` olduğundan emin olun
3. PostgreSQL'i yeniden başlatın

### "database does not exist" hatası:

```bash
sudo -u postgres psql -c "CREATE DATABASE kutahyaaricilarbirligi;"
```

### "permission denied" hatası:

```bash
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE kutahyaaricilarbirligi TO kutahyaaricilarbirligi;"
```

