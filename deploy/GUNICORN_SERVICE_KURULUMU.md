# 🔧 Gunicorn Service Kurulumu - Adım Adım

## 📋 Gunicorn Service Dosyasını Kopyalama

### ADIM 1: Dosyayı Sunucuya Yükleme

#### Yöntem 1: GitHub'dan (Eğer GitHub'a yüklediyseniz)

```bash
cd /var/www/kutahyaaricilarbirligi

# Değişiklikleri çek
git pull

# Dosya zaten proje klasöründe olacak
```

#### Yöntem 2: SCP ile (Windows'tan)

Windows PowerShell'de:

```powershell
scp C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi\deploy\gunicorn.service root@37.148.208.77:/tmp/gunicorn.service
```

#### Yöntem 3: WinSCP/FileZilla ile

1. WinSCP veya FileZilla'yı açın
2. Sunucuya bağlanın (37.148.208.77)
3. Sol tarafta (bilgisayarınız) `deploy/gunicorn.service` dosyasını bulun
4. Sağ tarafta (sunucu) `/tmp` klasörüne sürükleyip bırakın

### ADIM 2: Dosyayı Systemd Klasörüne Kopyalama

Sunucuda:

```bash
# Dosyayı systemd klasörüne kopyala
sudo cp /var/www/kutahyaaricilarbirligi/deploy/gunicorn.service /etc/systemd/system/

# VEYA eğer /tmp'ye yüklediyseniz:
sudo cp /tmp/gunicorn.service /etc/systemd/system/
```

### ADIM 3: Dosya İzinlerini Kontrol Etme

```bash
# Dosya izinlerini kontrol et
ls -la /etc/systemd/system/gunicorn.service

# İzinler şu şekilde olmalı:
# -rw-r--r-- 1 root root
```

### ADIM 4: Dosya İçeriğini Kontrol Etme

```bash
# Dosya içeriğini görüntüle
cat /etc/systemd/system/gunicorn.service
```

**Beklenen içerik:**
```ini
[Unit]
Description=Gunicorn daemon for kutahyaaricilarbirligi
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/kutahyaaricilarbirligi
ExecStart=/var/www/kutahyaaricilarbirligi/venv/bin/gunicorn \
    --access-logfile - \
    --workers 3 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    kutahyaaricilarbirligi.wsgi:application

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### ADIM 5: Yolları Kontrol Etme

Dosyadaki yolların doğru olduğundan emin olun:

```bash
# WorkingDirectory kontrolü
ls -la /var/www/kutahyaaricilarbirligi

# Gunicorn yolu kontrolü
ls -la /var/www/kutahyaaricilarbirligi/venv/bin/gunicorn

# WSGI dosyası kontrolü
ls -la /var/www/kutahyaaricilarbirligi/kutahyaaricilarbirligi/wsgi.py
```

Eğer yollar farklıysa, dosyayı düzenleyin:

```bash
sudo nano /etc/systemd/system/gunicorn.service
```

### ADIM 6: Systemd'yi Yeniden Yükleme

```bash
# Systemd'yi yeniden yükle (yeni service dosyasını tanıması için)
sudo systemctl daemon-reload
```

### ADIM 7: Gunicorn Service'i Etkinleştirme ve Başlatma

```bash
# Service'i etkinleştir (sistem açılışında otomatik başlasın)
sudo systemctl enable gunicorn

# Service'i başlat
sudo systemctl start gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

### ADIM 8: Service Durumunu Kontrol Etme

```bash
# Service durumu
sudo systemctl status gunicorn

# Service logları
sudo journalctl -u gunicorn -f

# Service'in çalışıp çalışmadığını kontrol et
sudo systemctl is-active gunicorn
```

## 🔧 Hızlı Komut (Hepsini Birden)

```bash
# Dosyayı kopyala
sudo cp /var/www/kutahyaaricilarbirligi/deploy/gunicorn.service /etc/systemd/system/

# Systemd'yi yeniden yükle
sudo systemctl daemon-reload

# Service'i etkinleştir ve başlat
sudo systemctl enable gunicorn
sudo systemctl start gunicorn

# Durumu kontrol et
sudo systemctl status gunicorn
```

## 🆘 Sorun Giderme

### Hata: "No such file or directory"

```bash
# Dosyanın varlığını kontrol et
ls -la /var/www/kutahyaaricilarbirligi/deploy/gunicorn.service

# Eğer yoksa, GitHub'dan çek veya manuel oluştur
```

### Hata: "Failed to start gunicorn.service"

```bash
# Logları kontrol et
sudo journalctl -u gunicorn -n 50

# Yolları kontrol et
ls -la /var/www/kutahyaaricilarbirligi/venv/bin/gunicorn
ls -la /var/www/kutahyaaricilarbirligi/kutahyaaricilarbirligi/wsgi.py

# Service dosyasını kontrol et
sudo nano /etc/systemd/system/gunicorn.service
```

### Hata: "Permission denied"

```bash
# www-data kullanıcısının proje klasörüne erişimi var mı?
sudo chown -R www-data:www-data /var/www/kutahyaaricilarbirligi
sudo chmod -R 755 /var/www/kutahyaaricilarbirligi
```

## ✅ Kontrol Listesi

- [ ] Gunicorn service dosyası `/etc/systemd/system/` klasöründe
- [ ] `systemctl daemon-reload` çalıştırıldı
- [ ] Service etkinleştirildi (`enable`)
- [ ] Service başlatıldı (`start`)
- [ ] Service durumu aktif (`status`)
- [ ] Port 8000'de dinliyor (`netstat -tlnp | grep 8000`)

## 🔄 Service Yönetimi

```bash
# Service'i durdur
sudo systemctl stop gunicorn

# Service'i başlat
sudo systemctl start gunicorn

# Service'i yeniden başlat
sudo systemctl restart gunicorn

# Service'i durdur ve devre dışı bırak
sudo systemctl stop gunicorn
sudo systemctl disable gunicorn

# Service loglarını canlı izle
sudo journalctl -u gunicorn -f
```


