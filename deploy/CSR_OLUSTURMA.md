# 🔐 CSR (Certificate Signing Request) Oluşturma - Nginx için

## 📋 Nginx için CSR Oluşturma

Formda "Server Tipi" seçerken:
- **"Apache + MOD SSL"** seçebilirsiniz (Nginx benzer SSL yapılandırması kullanır)
- VEYA daha iyi: CSR'ı sunucuda manuel oluşturun (aşağıdaki yöntem)

## 🚀 Sunucuda Manuel CSR Oluşturma (Önerilen)

### ADIM 1: Private Key Oluşturma

```bash
# Private key oluştur (2048 bit - önerilen)
openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048

# İzinleri ayarla (GÜVENLİK ÖNEMLİ!)
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
```

### ADIM 2: CSR Oluşturma

```bash
# CSR oluştur
openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key -out /tmp/kutahyaaricilarbirligi.com.csr
```

**Sorular sorulacak, şu şekilde cevaplayın:**

```
Country Name (2 letter code) [XX]: TR
State or Province Name (full name) []: Kütahya
Locality Name (eg, city) []: Kütahya
Organization Name (eg, company) []: Kütahya Arı Yetiştiricileri Birliği
Organizational Unit Name (eg, section) []: IT
Common Name (eg, your name or your server's hostname) []: kutahyaaricilarbirligi.com
Email Address []: admin@kutahyaaricilarbirligi.com

A challenge password []: (Boş bırakın, Enter'a basın)
An optional company name []: (Boş bırakın, Enter'a basın)
```

**ÖNEMLİ:** 
- **Common Name**: `kutahyaaricilarbirligi.com` veya `www.kutahyaaricilarbirligi.com` olmalı
- Diğer alanlar isteğe bağlı ama doldurmanız önerilir

### ADIM 3: CSR Dosyasını Kontrol Etme

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

### ADIM 4: CSR Dosyasını İndirme

**Windows'a indirmek için:**

```powershell
# PowerShell'de
scp root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.csr C:\Users\olc.atolye1\Downloads\
```

**VEYA WinSCP/FileZilla ile:**
1. Sunucuya bağlanın
2. `/tmp/kutahyaaricilarbirligi.com.csr` dosyasını bulun
3. Bilgisayarınıza indirin

### ADIM 5: CSR'ı Sertifika Firmasına Gönderme

1. İndirdiğiniz `.csr` dosyasını açın (Notepad ile)
2. Tüm içeriği kopyalayın (-----BEGIN ile -----END arasındaki her şey)
3. Sertifika oluşturma formundaki "CSR Üretimi" alanına yapıştırın
4. Formu gönderin

## 📝 Hızlı Komut (Hepsini Birden)

```bash
# Private key oluştur
sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key

# CSR oluştur (soruları cevaplayın)
sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key -out /tmp/kutahyaaricilarbirligi.com.csr

# CSR içeriğini görüntüle
cat /tmp/kutahyaaricilarbirligi.com.csr
```

## 🔍 CSR İçeriğini Kontrol Etme

```bash
# CSR detaylarını görüntüle
openssl req -in /tmp/kutahyaaricilarbirligi.com.csr -text -noout
```

## ⚠️ Önemli Notlar

1. **Private Key'i ASLA paylaşmayın!** Sadece CSR'ı gönderin.
2. **Private Key'i yedekleyin!** Sertifika geldiğinde bu key ile eşleşecek.
3. **Common Name** alanı domain adınızla tam olarak eşleşmeli.
4. **2048 bit** yeterli, 4096 bit daha güvenli ama daha yavaş.

## 📋 Form Doldurma (Eğer Manuel CSR Oluşturmuyorsanız)

Formda:
- **Server Tipi**: "Apache + MOD SSL" seçin
- **CSR Üretimi**: Sunucuda oluşturduğunuz CSR içeriğini yapıştırın
- **Bit Sayısı**: 2048 bit seçin

## ✅ Sertifika Geldikten Sonra

Sertifika dosyasını aldıktan sonra:
1. Sertifika dosyasını sunucuya yükleyin (önceki talimatlara göre)
2. Private key zaten sunucuda (`/etc/ssl/private/kutahyaaricilarbirligi.com.key`)
3. Nginx config'i güncelleyin
4. Nginx'i yeniden başlatın


