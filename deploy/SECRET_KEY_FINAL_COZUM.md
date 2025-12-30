# 🔐 SECRET_KEY Final Çözüm

## ⚠️ Sorun

`.env` dosyası oluşturuldu ama Django hala environment variable'ları okuyamıyor. Gunicorn service dosyasına `.env` dosyasını yüklememiz gerekiyor.

## 🔧 Çözüm: Gunicorn Service Dosyasını Güncelle

### ADIM 1: Gunicorn Service Dosyasını Güncelle

```bash
sudo nano /etc/systemd/system/gunicorn.service
```

Şu satırı bulun:
```ini
[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/kutahyaaricilarbirligi
ExecStart=...
```

Şu satırı ekleyin (WorkingDirectory'den sonra):
```ini
EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env
```

**Tam hali şöyle olmalı:**
```ini
[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/kutahyaaricilarbirligi
EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env
ExecStart=/var/www/kutahyaaricilarbirligi/venv/bin/gunicorn \
    --access-logfile - \
    --workers 3 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    kutahyaaricilarbirligi.wsgi:application
```

Nano'da:
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

### ADIM 2: .env Dosyasını Kontrol Et

```bash
# .env dosyasının varlığını kontrol et
ls -la /var/www/kutahyaaricilarbirligi/.env

# İçeriğini kontrol et (şifreler görünecek, dikkatli olun)
cat /var/www/kutahyaaricilarbirligi/.env
```

**.env dosyası şu formatta olmalı:**
```env
DJANGO_SECRET_KEY=django-insecure-abc123...
DEBUG=False
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GucluSifre_2025!
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

**ÖNEMLİ:** `.env` dosyasında `export` veya başka bir şey olmamalı, sadece `KEY=value` formatında olmalı!

### ADIM 3: Systemd ve Gunicorn'u Yeniden Başlat

```bash
# Systemd'yi yeniden yükle
sudo systemctl daemon-reload

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

### ADIM 4: Uyarının Gittiğini Kontrol Et

```bash
# Logları kontrol et
sudo journalctl -u gunicorn -n 20

# Uyarı artık görünmemeli
```

## 🚀 Hızlı Komut (Hepsini Birden)

```bash
# Gunicorn service dosyasını güncelle
sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service

# Systemd'yi yeniden yükle
sudo systemctl daemon-reload

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

## 🔍 Kontrol

```bash
# Uyarının gittiğini kontrol et
sudo journalctl -u gunicorn -n 20 | grep -i "secret\|warning"

# Eğer hiçbir şey çıkmazsa, başarılı!
```

## 🆘 Sorun Giderme

### Hata: "EnvironmentFile not found"

```bash
# .env dosyasının varlığını kontrol et
ls -la /var/www/kutahyaaricilarbirligi/.env

# Eğer yoksa oluştur
nano /var/www/kutahyaaricilarbirligi/.env
```

### Hata: "Invalid environment file"

`.env` dosyası formatı yanlış olabilir. Şu formatta olmalı:
```env
KEY=value
KEY2=value2
```

**YANLIŞ:**
```env
export KEY=value  # ❌
KEY = value       # ❌ (boşluk var)
```

**DOĞRU:**
```env
KEY=value         # ✅
```

## ✅ Başarı Kontrolü

- [ ] Gunicorn service dosyasında `EnvironmentFile` satırı var
- [ ] `.env` dosyası var ve doğru formatta
- [ ] `systemctl daemon-reload` yapıldı
- [ ] Gunicorn yeniden başlatıldı
- [ ] Loglarda SECRET_KEY uyarısı yok


