# 🔧 Log Klasörü Hatası Çözümü

## Sorun

```
FileNotFoundError: [Errno 2] No such file or directory: '/var/www/logs/django.log'
```

## Hızlı Çözüm

Sunucuda şu komutu çalıştırın:

```bash
cd /var/www/kutahyaaricilarbirligi
mkdir -p logs
chmod 755 logs
```

## Kalıcı Çözüm

Settings.py dosyası güncellendi. Artık log klasörü otomatik oluşturulacak.

Ama şimdilik manuel olarak oluşturun:

```bash
cd /var/www/kutahyaaricilarbirligi
mkdir -p logs
chmod 755 logs
```

## Database Ayarları Düzeltmesi

Settings.py'de database ayarları düzeltildi. Artık environment variable kullanıyor.

`.env` dosyasında şu şekilde olmalı:

```env
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
```

**VEYA** direkt settings.py'de (güvenlik açısından önerilmez ama çalışır):

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'kutahyaaricilarbirligi',
        'USER': 'kutahyaaricilarbirligi',
        'PASSWORD': 'GucluSifre_2025!',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

## Tüm Adımlar

```bash
# 1. Log klasörünü oluştur
cd /var/www/kutahyaaricilarbirligi
mkdir -p logs
chmod 755 logs

# 2. Settings.py'yi güncelle (GitHub'dan çek veya manuel düzenle)
# Database ayarlarını düzelt

# 3. Tekrar dene
source venv/bin/activate
python manage.py migrate
```


