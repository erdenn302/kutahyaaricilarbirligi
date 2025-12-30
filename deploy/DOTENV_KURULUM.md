# 🔧 .env Dosyası Otomatik Yükleme - python-dotenv

## ⚠️ Sorun

`collectstatic` ve diğer Django komutları çalıştırılırken `.env` dosyası otomatik olarak yüklenmiyor.

## ✅ Çözüm: python-dotenv

`python-dotenv` paketi `.env` dosyasını otomatik olarak yükler.

## 📦 Kurulum

### 1. requirements.txt Güncelle (Yerel)

```bash
# Windows'ta (yerel)
cd C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi
.\venv\Scripts\Activate.ps1
pip install python-dotenv
```

### 2. Sunucuda Kurulum

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
pip install python-dotenv
```

### 3. .env Dosyası Oluştur (Sunucuda)

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# Secret key oluştur
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Çıkan key'i kopyalayın, sonra:

```bash
nano .env
```

İçine şunu yapıştırın (SECRET_KEY'i yukarıdaki komuttan aldığınız değerle değiştirin):

```env
DJANGO_SECRET_KEY=buraya_yukaridaki_secret_key_yapistirin
DEBUG=False
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

Kaydedin (Ctrl+X, Y, Enter).

### 4. İzinleri Ayarla

```bash
chmod 600 .env
chown root:root .env
```

### 5. Test Et

```bash
python manage.py collectstatic --noinput
```

Artık uyarı görünmemeli! ✅

## 🔄 Gunicorn Service Güncelleme (Opsiyonel)

Gunicorn için de `.env` dosyasını yüklemek isterseniz:

```bash
sudo nano /etc/systemd/system/gunicorn.service
```

`WorkingDirectory` satırından sonra ekleyin:

```ini
EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env
```

Sonra:

```bash
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
```

## ✅ Kontrol

```bash
# Uyarı gitti mi?
python manage.py collectstatic --noinput

# Gunicorn loglarını kontrol et
sudo journalctl -u gunicorn -n 20 | grep -i "secret\|warning"
```


