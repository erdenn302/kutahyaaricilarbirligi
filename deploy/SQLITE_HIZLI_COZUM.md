# 🗄️ SQLite Hızlı Çözüm - PostgreSQL Hatası

## ⚠️ Sorun

PostgreSQL bağlantı hatası: `password authentication failed`

## ✅ Hızlı Çözüm: SQLite Kullan

Küçük-orta ölçekli siteler için SQLite yeterlidir. PostgreSQL kurulumu karmaşık olduğu için SQLite'a geçelim.

### ADIM 1: .env Dosyasını Güncelle

```bash
cd /var/www/kutahyaaricilarbirligi
nano .env
```

**DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT satırlarını silin veya yorum satırı yapın:**

```env
DJANGO_SECRET_KEY=your_secret_key_here
DEBUG=False
# DB_NAME=kutahyaaricilarbirligi
# DB_USER=kutahyaaricilarbirligi
# DB_PASSWORD=GucluSifre_2025!
# DB_HOST=localhost
# DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

Kaydedin (Ctrl+X, Y, Enter).

### ADIM 2: Migrations Çalıştır

```bash
source venv/bin/activate
python manage.py migrate
```

### ADIM 3: Superuser Oluştur (Gerekirse)

```bash
python manage.py createsuperuser
```

### ADIM 4: Test Et

```bash
python manage.py check
python manage.py collectstatic --noinput
```

## ✅ Başarılı!

Artık SQLite kullanılıyor ve site çalışmalı!

## 🔄 PostgreSQL İsterseniz

PostgreSQL kullanmak isterseniz, önce PostgreSQL'i kurup veritabanı oluşturmanız gerekir. Detaylar için `deploy/POSTGRESQL_KURULUM.md` dosyasına bakın.

