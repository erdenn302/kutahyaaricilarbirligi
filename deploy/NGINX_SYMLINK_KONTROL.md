# 🔗 Nginx Symlink Kontrolü

## ✅ Durum

Symlink zaten mevcut. Doğru yere işaret edip etmediğini kontrol edelim.

## 🔍 Kontrol

```bash
# Symlink'in doğru yere işaret ettiğini kontrol et
ls -la /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Beklenen çıktı:
# lrwxrwxrwx 1 root root 55 ... kutahyaaricilarbirligi -> /etc/nginx/sites-available/kutahyaaricilarbirligi
```

## ✅ Eğer Doğruysa

Symlink doğru yere işaret ediyorsa, hiçbir şey yapmanıza gerek yok! Devam edin:

```bash
# Nginx config test
sudo nginx -t

# Başarılıysa reload
sudo systemctl reload nginx
```

## 🔧 Eğer Yanlışsa

Eğer symlink yanlış yere işaret ediyorsa:

```bash
# Mevcut symlink'i kaldır
sudo rm /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Yeniden oluştur
sudo ln -s /etc/nginx/sites-available/kutahyaaricilarbirligi /etc/nginx/sites-enabled/

# Kontrol et
ls -la /etc/nginx/sites-enabled/kutahyaaricilarbirligi
```

## 🚀 Hızlı Kontrol

```bash
# Symlink kontrolü
readlink -f /etc/nginx/sites-enabled/kutahyaaricilarbirligi

# Beklenen çıktı:
# /etc/nginx/sites-available/kutahyaaricilarbirligi
```

Eğer doğru çıktıyı veriyorsa, symlink hazır! Devam edin.

