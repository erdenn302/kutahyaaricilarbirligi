# 📝 CSR Oluşturma - Basit Anlatım

## 🤔 CSR Nedir?

**CSR (Certificate Signing Request)** = Sertifika İmza İsteği

SSL sertifikası almak için önce CSR oluşturmanız gerekir. Bu CSR'ı sertifika firmasına gönderirsiniz, onlar size sertifika verir.

## 📋 Adım Adım CSR Oluşturma

### ADIM 1: Private Key Oluştur (Özel Anahtar)

Sunucuda:

```bash
cd /var/www/kutahyaaricilarbirligi

# Private key oluştur (2048 bit)
sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048

# İzinleri ayarla (GÜVENLİK ÖNEMLİ!)
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### ADIM 2: CSR Oluştur (Sertifika İsteği)

```bash
# CSR oluştur (sorular sorulacak)
sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key -out /tmp/kutahyaaricilarbirligi.com.csr
```

**Sorular geldiğinde şu şekilde cevaplayın:**

```
Country Name (2 letter code) [XX]: TR
State or Province Name (full name) []: Kutahya
Locality Name (eg, city) []: Kutahya
Organization Name (eg, company) []: Kutahya Aricilar Birligi
Organizational Unit Name (eg, section) []: IT
Common Name (eg, your name or your server's hostname) []: kutahyaaricilarbirligi.com
Email Address []: admin@kutahyaaricilarbirligi.com

A challenge password []: (Boş bırak, Enter'a bas)
An optional company name []: (Boş bırak, Enter'a bas)
```

**ÖNEMLİ:** 
- **Common Name**: `kutahyaaricilarbirligi.com` olmalı (domain adınız)
- Diğer alanlar isteğe bağlı ama doldurmanız önerilir

### ADIM 3: CSR İçeriğini Görüntüle

```bash
# CSR içeriğini görüntüle
cat /tmp/kutahyaaricilarbirligi.com.csr
```

**Çıktı şu şekilde olmalı:**
```
-----BEGIN CERTIFICATE REQUEST-----
MIIC... (uzun bir metin)
-----END CERTIFICATE REQUEST-----
```

### ADIM 4: CSR'ı Kopyala

Yukarıdaki çıktıyı **tamamen** kopyalayın (-----BEGIN ile -----END arasındaki her şey).

### ADIM 5: CSR'ı Sertifika Firmasına Gönder

1. SSL sertifika satın aldığınız firmanın web sitesine gidin
2. "Sertifika Oluşturma" veya "CSR Yükleme" bölümüne gidin
3. Kopyaladığınız CSR içeriğini yapıştırın
4. Formu gönderin
5. Sertifika dosyalarınızı alın (genellikle `.crt` ve `.key` dosyaları)

## 🚀 Hızlı Komut (Hepsini Birden)

```bash
cd /var/www/kutahyaaricilarbirligi && \
sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048 && \
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key && \
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key && \
sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key -out /tmp/kutahyaaricilarbirligi.com.csr -subj "/C=TR/ST=Kutahya/L=Kutahya/O=Kutahya Aricilar Birligi/OU=IT/CN=kutahyaaricilarbirligi.com/emailAddress=admin@kutahyaaricilarbirligi.com" && \
cat /tmp/kutahyaaricilarbirligi.com.csr
```

## 📥 CSR Dosyasını İndirme (Windows'a)

Windows bilgisayarınıza indirmek için:

**PowerShell'de:**
```powershell
scp root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.csr C:\Users\olc.atolye1\Downloads\
```

**VEYA WinSCP/FileZilla ile:**
1. Sunucuya bağlanın
2. `/tmp/kutahyaaricilarbirligi.com.csr` dosyasını bulun
3. Bilgisayarınıza indirin

## ✅ CSR Kontrolü

```bash
# CSR detaylarını görüntüle
openssl req -in /tmp/kutahyaaricilarbirligi.com.csr -text -noout
```

## 🔄 Sertifika Geldikten Sonra

Sertifika dosyalarını aldıktan sonra:

1. Sertifika dosyasını sunucuya yükleyin
2. Private key zaten sunucuda (`/etc/ssl/private/kutahyaaricilarbirligi.com.key`)
3. Nginx config'i güncelleyin
4. Nginx'i yeniden başlatın

## ⚠️ ÖNEMLİ NOTLAR

1. **Private Key'i ASLA paylaşmayın!** Sadece CSR'ı gönderin.
2. **Private Key'i yedekleyin!** Sertifika geldiğinde bu key ile eşleşecek.
3. **Common Name** alanı domain adınızla tam olarak eşleşmeli.
4. **2048 bit** yeterli, 4096 bit daha güvenli ama daha yavaş.

## 🎯 Özet

1. ✅ Private key oluştur → `/etc/ssl/private/kutahyaaricilarbirligi.com.key`
2. ✅ CSR oluştur → `/tmp/kutahyaaricilarbirligi.com.csr`
3. ✅ CSR içeriğini kopyala
4. ✅ Sertifika firmasına gönder
5. ✅ Sertifika dosyalarını al
6. ✅ Sunucuya yükle ve Nginx'i yapılandır

