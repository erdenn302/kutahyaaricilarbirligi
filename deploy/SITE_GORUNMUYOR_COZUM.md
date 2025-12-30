# 🌐 Site Görünmüyor - Sorun Giderme

## ✅ Durum: Sunucu Çalışıyor (HTTP 200 OK)

Sunucu çalışıyor ama tarayıcıda görünmüyor. Olası nedenler:

## 🔍 Kontrol Listesi

### 1. DNS Kontrolü

Domain'in IP'ye yönlendirilip yönlendirilmediğini kontrol edin:

```bash
# DNS kontrolü
nslookup kutahyaaricilarbirligi.com
dig kutahyaaricilarbirligi.com
```

IP adresi `37.148.208.77` olmalı.

**Eğer DNS ayarlanmamışsa:**
- Domain sağlayıcınızın DNS ayarlarına gidin
- A kaydı ekleyin: `kutahyaaricilarbirligi.com` → `37.148.208.77`
- A kaydı ekleyin: `www.kutahyaaricilarbirligi.com` → `37.148.208.77`

### 2. IP ile Erişim Testi

```bash
# IP ile test (sunucuda)
curl -I http://37.148.208.77

# Tarayıcıda test
# http://37.148.208.77 adresini açın
```

Eğer IP ile açılıyorsa → DNS sorunu
Eğer IP ile de açılmıyorsa → Başka bir sorun var

### 3. Static Files Kontrolü

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# Static files var mı?
ls -la staticfiles/

# Static files topla
python manage.py collectstatic --noinput

# İzinleri kontrol et
sudo chown -R www-data:www-data staticfiles
```

### 4. Tarayıcı Kontrolü

- **Hard Refresh:** `Ctrl + F5` (Windows) veya `Cmd + Shift + R` (Mac)
- **Cache Temizle:** Tarayıcı ayarlarından cache'i temizleyin
- **Farklı Tarayıcı:** Başka bir tarayıcıda deneyin
- **Incognito/Private Mode:** Gizli modda açın

### 5. Firewall Kontrolü

```bash
# Firewall durumu
sudo ufw status

# Port 80 açık mı?
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### 6. Nginx Log Kontrolü

```bash
# Erişim logları
sudo tail -50 /var/log/nginx/kutahyaaricilarbirligi_access.log

# Hata logları
sudo tail -50 /var/log/nginx/kutahyaaricilarbirligi_error.log
```

### 7. Gunicorn Log Kontrolü

```bash
# Gunicorn logları
sudo journalctl -u gunicorn -n 50 --no-pager
```

### 8. Site İçeriği Kontrolü

```bash
# Site içeriğini görüntüle
curl http://kutahyaaricilarbirligi.com

# HTML çıktısı geliyor mu kontrol et
```

## 🚀 Hızlı Çözüm Scripti

```bash
bash deploy/SITE_GORUNMUYOR_HIZLI_COZUM.sh
```

