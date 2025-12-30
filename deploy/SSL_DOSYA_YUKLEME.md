# 🔐 SSL Sertifika Dosyası Yükleme - Nginx

## 📋 Server Tipi

**Server Tipi: Nginx** (Apache değil)

Django + Gunicorn + Nginx kullanıyoruz.

## 📥 SSL Sertifika Dosyası Yükleme

### ADIM 1: Sertifika Dosyasını Hazırlayın

Natro'dan indirdiğiniz sertifika dosyası genellikle şu formatta olur:
- `.crt` veya `.pem` uzantılı
- Örnek: `kutahyaaricilarbirligi.com.crt` veya `certificate.crt`

### ADIM 2: Dosyayı Sunucuya Yükleyin

#### Yöntem 1: WinSCP/FileZilla (Önerilen)

1. **WinSCP** veya **FileZilla** programını açın
2. Sunucuya bağlanın:
   - **Host**: 37.148.208.77
   - **Kullanıcı**: root
   - **Şifre**: sunucu şifreniz
   - **Port**: 22 (SSH)
3. Sol tarafta (bilgisayarınız) sertifika dosyasını bulun
4. Sağ tarafta (sunucu) `/tmp` klasörüne gidin
5. Sertifika dosyasını sürükleyip bırakın
6. Dosya adını şu şekilde değiştirin: `kutahyaaricilarbirligi.com.crt`

#### Yöntem 2: SCP ile (Windows PowerShell)

```powershell
# Sertifika dosyasını yükle
scp C:\yol\sertifika.crt root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.crt
```

### ADIM 3: Sunucuda SSL Kurulum Script'ini Çalıştırın

Dosyayı yükledikten sonra sunucuda:

```bash
cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate
git pull origin main
bash deploy/SSL_TAM_KURULUM.sh
```

Script size soracak:
- CSR oluşturmak istiyor musunuz? → `h` (hayır, zaten var)
- Script `/tmp` klasöründeki sertifika dosyasını bulacak ve taşıyacak
- SSL kurulum script'ini otomatik çalıştıracak

### ADIM 4: Manuel Kurulum (Script Çalışmazsa)

```bash
# 1. Sertifika dosyasını güvenli yere taşı
sudo mkdir -p /etc/ssl/certs
sudo mv /tmp/kutahyaaricilarbirligi.com.crt /etc/ssl/certs/

# 2. İzinleri ayarla
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt

# 3. Private key kontrolü (CSR oluştururken oluşturulmuş olmalı)
ls -la /etc/ssl/private/kutahyaaricilarbirligi.com.key

# 4. SSL kurulum script'ini çalıştır
bash deploy/SSL_KURULUM_ADIM_ADIM.sh
```

## 🔍 Kontrol

Kurulumdan sonra:

```bash
# SSL kontrol script'ini çalıştır
bash deploy/SSL_KONTROL.sh
```

## 📝 Notlar

1. **Private Key**: CSR oluştururken private key dosyası zaten oluşturulmuş olmalı (`/etc/ssl/private/kutahyaaricilarbirligi.com.key`)

2. **Dosya Formatı**: Sertifika dosyası `.crt`, `.pem` veya `.cer` olabilir, hepsi çalışır

3. **Server Tipi**: Natro'da "Server Tipi" seçerken **Nginx** seçin (Apache değil)

4. **CA Bundle**: Eğer ara sertifika zinciri (intermediate certificate) dosyanız varsa, onu da yükleyin

## ✅ Başarı Kontrolü

- [ ] Sertifika dosyası `/tmp` klasörüne yüklendi
- [ ] Script çalıştırıldı ve sertifika taşındı
- [ ] SSL kontrol script'i başarılı
- [ ] HTTPS çalışıyor: `https://37.148.208.77`

