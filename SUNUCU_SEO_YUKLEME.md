# 🚀 SEO İyileştirmelerini Sunucuya Yükleme

## 📋 Hızlı Yükleme (Tek Komut)

Sunucuda şu komutu çalıştırın:

```bash
cd /var/www/kutahyaaricilarbirligi && \
source venv/bin/activate && \
git pull origin main && \
python manage.py makemigrations && \
python manage.py migrate && \
python manage.py collectstatic --noinput && \
sudo systemctl restart gunicorn && \
sudo systemctl reload nginx
```

## 🔧 Adım Adım Yükleme

### 1. Sunucuya Bağlanın
```bash
ssh root@37.148.208.77
```

### 2. Proje Klasörüne Gidin
```bash
cd /var/www/kutahyaaricilarbirligi
```

### 3. Virtual Environment'ı Aktif Edin
```bash
source venv/bin/activate
```

### 4. Git Pull (Güncellemeleri Çekin)
```bash
git stash  # Varsa yerel değişiklikleri sakla
git pull origin main
```

### 5. Veritabanı Güncellemeleri
```bash
python manage.py makemigrations
python manage.py migrate
```

### 6. Static Files Toplama
```bash
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles
```

### 7. Gunicorn Yeniden Başlatma
```bash
sudo systemctl restart gunicorn
```

### 8. Nginx Yeniden Yükleme
```bash
sudo systemctl reload nginx
```

## ✅ Test Etme

### Sitemap Kontrolü
```bash
curl -I https://www.kutahyaaricilarbirligi.com/sitemap.xml
# veya
curl -I http://37.148.208.77/sitemap.xml
```

### Robots.txt Kontrolü
```bash
curl -I https://www.kutahyaaricilarbirligi.com/robots.txt
# veya
curl -I http://37.148.208.77/robots.txt
```

### Site Kontrolü
```bash
curl -I https://www.kutahyaaricilarbirligi.com
```

## 🎯 Script ile Yükleme (ÖNERİLEN)

Script'i çalıştırılabilir yapın ve çalıştırın:

```bash
cd /var/www/kutahyaaricilarbirligi
chmod +x deploy/SEO_YUKLEME.sh
bash deploy/SEO_YUKLEME.sh
```

## 🔍 Sorun Giderme

### Git Pull Hatası
```bash
git stash
git pull origin main
```

### Migration Hatası
```bash
python manage.py migrate --run-syncdb
```

### Gunicorn Başlamıyor
```bash
sudo systemctl status gunicorn
sudo journalctl -u gunicorn -n 50
```

### Nginx Hatası
```bash
sudo nginx -t
sudo systemctl status nginx
```

## 📊 Başarı Kontrolü

Tüm bu komutlar başarılı olursa:

✅ Sitemap: `https://www.kutahyaaricilarbirligi.com/sitemap.xml` → HTTP 200
✅ Robots.txt: `https://www.kutahyaaricilarbirligi.com/robots.txt` → HTTP 200
✅ Site: `https://www.kutahyaaricilarbirligi.com` → HTTP 200

## 🎉 Sonraki Adımlar

1. ✅ SEO dosyaları yüklendi
2. ⏳ Google Search Console'a site ekleyin (GOOGLE_SEO_REHBERI.md'ye bakın)
3. ⏳ Sitemap'i Google'a gönderin
4. ⏳ İndeksleme isteği yapın

---

**Not**: Tüm komutları root kullanıcısı ile veya sudo ile çalıştırın.

