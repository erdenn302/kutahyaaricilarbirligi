# 🔗 Nginx Symlink Çözümü

## Sorun

Symlink zaten mevcut. Kontrol edip gerekirse yeniden oluşturalım.

## 🔍 ADIM 1: Mevcut Symlink'i Kontrol Et

```bash
# Symlink'in varlığını kontrol et
ls -la /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Config dosyasının varlığını kontrol et
ls -la /etc/nginx/sites-available/kutahyaaricilarbirligi
```

## 🔧 ADIM 2: Çözüm Seçenekleri

### Seçenek 1: Mevcut Symlink'i Kaldır ve Yeniden Oluştur

```bash
# Mevcut symlink'i kaldır
sudo rm /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Yeniden oluştur
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# Kontrol et
ls -la /etc/nginx/sites-enabled/kutahyaaricilarbirligi
```

### Seçenek 2: Symlink Doğru mu Kontrol Et

```bash
# Symlink'in doğru yere işaret ettiğini kontrol et
readlink -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Eğer doğru yere işaret ediyorsa, hiçbir şey yapmanıza gerek yok!
```

### Seçenek 3: Symlink Zaten Doğruysa Devam Et

Eğer symlink doğru yere işaret ediyorsa, sadece nginx'i test edin:

```bash
# Nginx config test
sudo nginx -t

# Başarılıysa reload
sudo systemctl reload nginx
```

## ✅ Hızlı Komut (Symlink'i Yeniden Oluştur)

```bash
# Mevcut symlink'i kaldır ve yeniden oluştur
sudo rm -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi && \
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/ && \
ls -la /etc/nginx/sites-enabled/kutahyaaricilarbirligi
```

## 🔍 Kontrol

```bash
# Symlink'in doğru olduğunu kontrol et
ls -la /etc/nginx/sites-enabled/ | grep kutahyaaricilarbirligi

# Beklenen çıktı:
# lrwxrwxrwx 1 root root 55 ... kutahyaaricilarbirligi -> /etc/nginx/sites-available/kutahyaaricilarbirligi
```

## 📋 Tüm Nginx Kurulum Adımları

```bash
# 1. Config dosyasını kopyala (eğer yoksa)
sudo cp /var/www/kutahyaaricilarbirligi/deploy/nginx.conf /etc/nginx/sites-available/kutahyaaricilarbirligi

# 2. SSL sertifika yollarını düzenle (gerekirse)
sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi

# 3. Symlink oluştur (mevcut varsa kaldır)
sudo rm -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# 4. Default site'ı devre dışı bırak (opsiyonel)
sudo rm -f /etc/nginx/sites-enabled/default

# 5. Nginx config test
sudo nginx -t

# 6. Başarılıysa reload
sudo systemctl reload nginx

# 7. Durumu kontrol et
sudo systemctl status nginx
```

