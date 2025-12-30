# 🔒 SSL Sertifikası Yükleme - Adım Adım Rehber

## 📋 Ön Hazırlık

SSL sertifikanız genellikle 2 dosyadan oluşur:
1. **Certificate (Sertifika)**: `.crt` veya `.pem` uzantılı
2. **Private Key (Özel Anahtar)**: `.key` uzantılı

Bu dosyalar bilgisayarınızda olmalı. Eğer yoksa, SSL sertifikanızı aldığınız yerden (hosting firması, Let's Encrypt, vs.) indirmeniz gerekir.

## 🚀 Adım Adım Yükleme

### ADIM 1: Sertifika Dosyalarını Sunucuya Yükleme

#### Yöntem 1: SCP ile (Windows PowerShell veya Linux/Mac Terminal)

Windows bilgisayarınızdan:

```powershell
# PowerShell'de
scp C:\yol\sertifika.crt root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.crt
scp C:\yol\private.key root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.key
```

**Örnek:**
```powershell
scp C:\Users\olc.atolye1\Downloads\kutahyaaricilarbirligi.crt root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.crt
scp C:\Users\olc.atolye1\Downloads\kutahyaaricilarbirligi.key root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.key
```

#### Yöntem 2: WinSCP veya FileZilla ile (Görsel Arayüz)

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

#### Yöntem 3: Nano ile Manuel Oluşturma (Eğer dosyalarınız metin formatındaysa)

Sunucuda:

```bash
# Sertifika dosyasını oluştur
sudo nano /tmp/kutahyaaricilarbirligi.com.crt
```

Dosya içeriğini yapıştırın (-----BEGIN CERTIFICATE----- ile başlayan kısım), sonra:
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

```bash
# Private key dosyasını oluştur
sudo nano /tmp/kutahyaaricilarbirligi.com.key
```

Dosya içeriğini yapıştırın (-----BEGIN PRIVATE KEY----- ile başlayan kısım), sonra:
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

### ADIM 2: Dosyaları Güvenli Yere Taşıma

Sunucuda şu komutları çalıştırın:

```bash
# Klasörleri oluştur (eğer yoksa)
sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private

# Dosyaları taşı
sudo mv /tmp/kutahyaaricilarbirligi.com.crt /etc/ssl/certs/
sudo mv /tmp/kutahyaaricilarbirligi.com.key /etc/ssl/private/
```

### ADIM 3: Dosya İzinlerini Ayarlama (GÜVENLİK ÖNEMLİ!)

```bash
# Sertifika dosyası: Herkes okuyabilir ama sadece root yazabilir
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt

# Private key: Sadece root okuyabilir ve yazabilir (ÇOK ÖNEMLİ!)
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Sahiplik ayarları
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### ADIM 4: Dosyaların Doğru Yüklendiğini Kontrol Etme

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

### ADIM 5: Nginx Config Dosyasını Güncelleme

```bash
# Nginx config dosyasını düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Şu satırları bulun (yaklaşık 30-35. satırlar):

```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
```

**Eğer bu satırlar farklı yollara işaret ediyorsa, yukarıdaki yollarla değiştirin.**

Örnek: Eğer şu şekildeyse:
```nginx
ssl_certificate /path/to/certificate.crt;
ssl_certificate_key /path/to/private.key;
```

Şu şekilde değiştirin:
```nginx
ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;
ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;
```

**Nano'da:**
- İlgili satırları bulun
- Düzenleyin
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

### ADIM 6: Nginx Config'i Test Etme

```bash
# Config dosyasında hata var mı kontrol et
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

# Veya tamamen yeniden başlat
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

## 🔍 Sorun Giderme

### Hata: "No such file or directory"

```bash
# Dosya yollarını kontrol et
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

### Nginx test başarısız

```bash
# Hata mesajını oku
sudo nginx -t

# Error log'a bak
sudo tail -20 /var/log/nginx/error.log
```

## 📝 Özet Komutlar (Hepsini Birden)

```bash
# 1. Dosyaları taşı (eğer /tmp'ye yüklediyseniz)
sudo mkdir -p /etc/ssl/certs /etc/ssl/private
sudo mv /tmp/kutahyaaricilarbirligi.com.crt /etc/ssl/certs/
sudo mv /tmp/kutahyaaricilarbirligi.com.key /etc/ssl/private/

# 2. İzinleri ayarla
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key

# 3. Nginx config'i düzenle
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi
# (SSL yollarını güncelleyin)

# 4. Test ve yeniden başlat
sudo nginx -t
sudo systemctl reload nginx
```

## ❓ Sık Sorulan Sorular

**S: Sertifika dosyalarımı nerede bulabilirim?**
A: SSL sertifikanızı aldığınız yerden (hosting firması, cPanel, vs.) indirmeniz gerekir. Genellikle `.crt` ve `.key` uzantılı 2 dosya olur.

**S: Dosya isimleri farklıysa?**
A: Önemli değil, sadece `/etc/ssl/certs/` ve `/etc/ssl/private/` klasörlerine kopyalayın ve Nginx config'te doğru isimleri yazın.

**S: CA Bundle dosyası varsa?**
A: Eğer ara sertifika zinciri (intermediate certificate) dosyanız varsa, onu da yükleyin ve Nginx config'e `ssl_trusted_certificate` satırı ekleyin.


