# 🔒 SSL Sertifikası Sıfırdan Kurulum

## 📋 Adım Adım SSL Kurulumu

### ADIM 1: SSL Sertifika Dosyalarını Hazırlama

SSL sertifikanız genellikle 2 dosyadan oluşur:
1. **Certificate (Sertifika)**: `.crt` veya `.pem` uzantılı
2. **Private Key (Özel Anahtar)**: `.key` uzantılı

Bu dosyalar bilgisayarınızda olmalı. Eğer yoksa, SSL sertifikanızı aldığınız yerden indirmeniz gerekir.

### ADIM 2: Sertifika Dosyalarını Sunucuya Yükleme

#### Yöntem 1: WinSCP/FileZilla ile (Önerilen)

1. **WinSCP** veya **FileZilla** programını açın
2. Sunucuya bağlanın:
   - **Host**: 37.148.208.77
   - **Kullanıcı**: root
   - **Şifre**: sunucu şifreniz
   - **Port**: 22 (SSH)
3. Sol tarafta (bilgisayarınız) sertifika dosyalarınızı bulun
4. Sağ tarafta (sunucu) `/tmp` klasörüne gidin
5. İki dosyayı sürükleyip bırakın:
   - `kutahyaaricilarbirligi.com.crt` (veya .pem)
   - `kutahyaaricilarbirligi.com.key`

#### Yöntem 2: SCP ile (Windows PowerShell)

```powershell
# Sertifika dosyasını yükle
scp C:\yol\sertifika.crt root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.crt

# Private key dosyasını yükle
scp C:\yol\private.key root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.key
```

### ADIM 3: Sertifika Dosyalarını Güvenli Yere Taşıma

Sunucuda:

```bash
# Klasörleri oluştur
sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private

# Dosyaları taşı
sudo mv /tmp/kutahyaaricilarbirligi.com.crt /etc/ssl/certs/
sudo mv /tmp/kutahyaaricilarbirligi.com.key /etc/ssl/private/

# İzinleri ayarla (GÜVENLİK ÖNEMLİ!)
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### ADIM 4: Sertifika Dosyalarını Kontrol Etme

```bash
# Dosyaların varlığını kontrol et
ls -la /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# İçeriklerini kontrol et (ilk birkaç satır)
head -5 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
head -5 /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

**Beklenen çıktı:**
- `.crt` dosyası: `-----BEGIN CERTIFICATE-----` ile başlamalı
- `.key` dosyası: `-----BEGIN PRIVATE KEY-----` veya `-----BEGIN RSA PRIVATE KEY-----` ile başlamalı

### ADIM 5: Nginx Config Dosyasını Oluşturma

```bash
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Aşağıdaki içeriği yapıştırın:

```nginx
# HTTP'den HTTPS'e yönlendirme
server {
    listen 80;
    listen [::]:80;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;
    
    # Tüm trafiği HTTPS'e yönlendir
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name kutahyaaricilarbirligi.com www.kutahyaaricilarbirligi.com;

    # SSL Sertifikaları
    ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
    ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
    
    # SSL Ayarları
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Logs
    access_log /var/log/nginx/kutahyaaricilarbirligi_access.log;
    error_log /var/log/nginx/kutahyaaricilarbirligi_error.log;
    
    # Client max body size (dosya yükleme için)
    client_max_body_size 10M;
    
    # Static files
    location /static/ {
        alias /var/www/kutahyaaricilarbirligi/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Media files
    location /media/ {
        alias /var/www/kutahyaaricilarbirligi/media/;
        expires 7d;
        add_header Cache-Control "public";
    }
    
    # Django uygulaması
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # WebSocket desteği (gerekirse)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Nano'da:
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

### ADIM 6: Nginx Config Test

```bash
# Config dosyasını test et
sudo nginx -t
```

**Başarılı çıktı:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### ADIM 7: Nginx'i Yeniden Başlatma

```bash
# Nginx'i yeniden başlat
sudo systemctl reload nginx

# VEYA tamamen yeniden başlat
sudo systemctl restart nginx

# Durumu kontrol et
sudo systemctl status nginx
```

### ADIM 8: SSL Sertifikasını Test Etme

```bash
# SSL bağlantısını test et
openssl s_client -connect kutahyaaricilarbirligi.com:443 -servername kutahyaaricilarbirligi.com
```

**Tarayıcıdan test:**
1. Tarayıcınızda: `https://kutahyaaricilarbirligi.com` adresine gidin
2. Adres çubuğunda kilit ikonu görünmeli
3. Kilit ikonuna tıklayıp sertifika detaylarını kontrol edin

## 🚀 Hızlı Komut (Hepsini Birden)

```bash
# 1. Klasörleri oluştur
sudo mkdir -p /etc/ssl/certs /etc/ssl/private

# 2. Dosyaları taşı (eğer /tmp'ye yüklediyseniz)
sudo mv /tmp/kutahyaaricilarbirligi.com.crt /etc/ssl/certs/ 2>/dev/null
sudo mv /tmp/kutahyaaricilarbirligi.com.key /etc/ssl/private/ 2>/dev/null

# 3. İzinleri ayarla
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key

# 4. Nginx config test
sudo nginx -t

# 5. Başarılıysa reload
sudo systemctl reload nginx
```

## 🔍 Sorun Giderme

### Hata: "No such file or directory"

```bash
# Sertifika dosyalarının varlığını kontrol et
ls -la /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Eğer dosyalar farklı bir yerdeyse, o yolu kullanın
```

### Hata: "Permission denied"

```bash
# İzinleri tekrar ayarlayın
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### Hata: "SSL certificate problem"

```bash
# Sertifika dosyasının formatını kontrol et
openssl x509 -in /etc/ssl/certs/kutahyaaricilarbirligi.com.crt -text -noout

# Private key'in formatını kontrol et
openssl rsa -in /etc/ssl/private/kutahyaaricilarbirligi.com.key -check
```

## ✅ Başarı Kontrolü

- [ ] Sertifika dosyaları `/etc/ssl/certs/` ve `/etc/ssl/private/` klasörlerinde
- [ ] Dosya izinleri doğru (644 ve 600)
- [ ] Nginx config test başarılı
- [ ] Nginx reload başarılı
- [ ] https://kutahyaaricilarbirligi.com açılıyor
- [ ] Kilit ikonu görünüyor

## 📝 Notlar

1. **CA Bundle**: Eğer ara sertifika zinciri (intermediate certificate) dosyanız varsa, onu da yükleyin ve Nginx config'e `ssl_trusted_certificate` satırı ekleyin.

2. **Sertifika Süresi**: Sertifikanızın geçerlilik süresini kontrol edin:
   ```bash
   openssl x509 -in /etc/ssl/certs/kutahyaaricilarbirligi.com.crt -noout -dates
   ```

3. **Backup**: Sertifika dosyalarınızın yedeğini alın ve güvenli bir yerde saklayın.

