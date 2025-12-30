# 🔐 SECRET_KEY Uyarısı Düzeltme

## ⚠️ Sorun

Gunicorn loglarında şu uyarı var:
```
SECRET_KEY environment variable not set! Using development key. This is UNSAFE for production!
```

## 🔧 Çözüm: .env Dosyası Oluşturma

### ADIM 1: Secret Key Oluştur

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# Secret key oluştur
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Çıkan key'i kopyalayın (örnek: `django-insecure-abc123...`)

### ADIM 2: .env Dosyası Oluştur

```bash
nano .env
```

İçeriği:

```env
DJANGO_SECRET_KEY=OLUŞTURDUĞUNUZ_SECRET_KEY_BURAYA
DEBUG=False
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

**ÖNEMLİ:** `OLUŞTURDUĞUNUZ_SECRET_KEY_BURAYA` yerine yukarıdaki komuttan aldığınız key'i yazın!

Nano'da:
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

### ADIM 3: .env Dosyası İzinlerini Ayarla

```bash
# Sadece root okuyabilir
chmod 600 .env
chown root:root .env
```

### ADIM 4: Gunicorn'u Yeniden Başlat

```bash
# Systemd'yi yeniden yükle (uyarı için)
sudo systemctl daemon-reload

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

### ADIM 5: Uyarının Gittiğini Kontrol Et

```bash
# Logları kontrol et
sudo journalctl -u gunicorn -n 20

# Uyarı artık görünmemeli
```

## 🚀 Hızlı Komut (Hepsini Birden)

```bash
cd /var/www/kutahyaaricilarbirligi && \
source venv/bin/activate && \
SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())") && \
cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DEBUG=False
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
EOF
chmod 600 .env && \
sudo systemctl daemon-reload && \
sudo systemctl restart gunicorn
```

## ✅ Kontrol

```bash
# Gunicorn loglarında uyarı olmamalı
sudo journalctl -u gunicorn -n 20 | grep -i "secret\|warning"

# Site çalışıyor mu?
curl -I http://localhost
```

## 🔒 Güvenlik Notları

1. **.env dosyası**: Asla GitHub'a yüklenmemeli (`.gitignore`'da)
2. **Secret Key**: Her production ortamında farklı olmalı
3. **İzinler**: `.env` dosyası sadece root tarafından okunabilir olmalı (chmod 600)

