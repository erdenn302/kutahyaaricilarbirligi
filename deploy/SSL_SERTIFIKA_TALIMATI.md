# 🔒 SSL Sertifikası Yükleme Talimatları

## Mevcut SSL Sertifikanızı Kullanma

Sunucunuzda zaten bir SSL sertifikanız var. Bu sertifikayı Nginx ile kullanmak için:

### 1. Sertifika Dosyalarını Sunucuya Yükleme

SSL sertifika dosyalarınızı sunucuya yükleyin. Genellikle şu dosyalar gerekir:
- **Certificate File** (.crt veya .pem): Sertifika dosyası
- **Private Key File** (.key): Özel anahtar dosyası
- **CA Bundle** (opsiyonel): Ara sertifika zinciri

### 2. Sertifika Dosyalarını Güvenli Yere Kopyalama

```bash
# Sertifika dosyalarını güvenli bir yere kopyalayın
sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private

# Sertifika dosyalarını kopyalayın
sudo cp /path/to/your/certificate.crt /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo cp /path/to/your/private.key /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Dosya izinlerini ayarlayın (GÜVENLİK ÖNEMLİ!)
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### 3. Nginx Config Dosyasını Güncelleme

`/etc/nginx/sites-available/kutahyaaricilarbirligi` dosyasını düzenleyin:

```bash
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Şu satırları bulun ve gerçek dosya yollarınızla değiştirin:

```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
```

**Eğer CA Bundle dosyanız varsa:**

```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
```

### 4. Nginx Config Test ve Yeniden Başlatma

```bash
# Config dosyasını test et
sudo nginx -t

# Hata yoksa Nginx'i yeniden başlat
sudo systemctl reload nginx
```

### 5. SSL Sertifikasını Test Etme

```bash
# SSL bağlantısını test et
openssl s_client -connect kutahyaaricilarbirligi.com:443 -servername kutahyaaricilarbirligi.com

# Tarayıcıdan test
# https://kutahyaaricilarbirligi.com
```

## 🔍 Sertifika Dosya Formatları

### PEM Format (En Yaygın)
- `.crt`, `.pem`, `.cer` uzantılı
- Text formatında, `-----BEGIN CERTIFICATE-----` ile başlar

### DER Format
- Binary format
- `.der` uzantılı

### PKCS#12 Format
- `.p12` veya `.pfx` uzantılı
- Şifre korumalı

**PEM formatına dönüştürme (gerekirse):**

```bash
# DER'den PEM'e
openssl x509 -inform DER -in certificate.der -out certificate.crt

# PKCS#12'den PEM'e
openssl pkcs12 -in certificate.p12 -out certificate.crt -nodes
```

## ⚠️ Güvenlik Notları

1. **Private Key Güvenliği**: Private key dosyası (`*.key`) asla paylaşılmamalı ve sadece root kullanıcısı tarafından okunabilir olmalıdır (chmod 600).

2. **Dosya İzinleri**:
   - Certificate: `644` (root:root)
   - Private Key: `600` (root:root)

3. **Backup**: Sertifika dosyalarınızın yedeğini alın ve güvenli bir yerde saklayın.

4. **Sertifika Süresi**: Sertifikanızın geçerlilik süresini kontrol edin:
   ```bash
   openssl x509 -in /etc/ssl/certs/kutahyaaricilarbirligi.com.crt -noout -dates
   ```

## 🔄 Sertifika Yenileme

Sertifikanızın süresi dolmadan önce yenileyin. Yenileme işleminden sonra:

```bash
# Yeni sertifika dosyalarını yükleyin
sudo cp new_certificate.crt /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo cp new_private.key /etc/ssl/private/kutahyaaricilarbirligi.com.key

# İzinleri ayarlayın
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Nginx'i yeniden başlatın
sudo systemctl reload nginx
```

## 📞 Destek

Sertifika ile ilgili sorun yaşarsanız:
1. Nginx error loglarını kontrol edin: `sudo tail -f /var/log/nginx/error.log`
2. SSL bağlantısını test edin: `openssl s_client -connect kutahyaaricilarbirligi.com:443`
3. Sertifika dosyalarının varlığını ve izinlerini kontrol edin


