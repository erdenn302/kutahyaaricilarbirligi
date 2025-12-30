# 📤 GitHub'a Güncelleme - Adım Adım

## 🎯 Yapılacaklar

1. Tüm değişiklikleri commit et
2. GitHub'a push et
3. Sunucuda pull et

## 🚀 Windows'ta Yapılacaklar

### ADIM 1: Git Durumunu Kontrol Et

```powershell
cd C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi
git status
```

### ADIM 2: Tüm Değişiklikleri Ekle

```powershell
# Tüm değişiklikleri ekle
git add .

# Durumu kontrol et
git status
```

### ADIM 3: Commit Yap

```powershell
git commit -m "Production deployment hazırlığı: Settings.py güncellemeleri, log klasörü düzeltmesi, database ayarları, SSL sertifika talimatları, deployment dokümantasyonu"
```

### ADIM 4: GitHub'a Push Et

```powershell
# Eğer ilk kez push ediyorsanız
git remote add origin https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
git branch -M main
git push -u origin main

# Eğer daha önce push ettiyseniz
git push origin main
```

## 🔍 Kontrol Listesi

Commit etmeden önce kontrol edin:

- [ ] `.env` dosyası `.gitignore`'da (GitHub'a yüklenmemeli)
- [ ] `db.sqlite3` dosyası `.gitignore`'da
- [ ] `venv/` klasörü `.gitignore`'da
- [ ] `media/` klasörü `.gitignore`'da
- [ ] Secret key'ler kodda yok
- [ ] Tüm önemli dosyalar eklendi

## 📋 Eklenmesi Gereken Dosyalar

Şu dosyalar mutlaka GitHub'da olmalı:

- ✅ `requirements.txt` (güncellenmiş)
- ✅ `kutahyaaricilarbirligi/settings.py` (güncellenmiş)
- ✅ `deploy/` klasöründeki tüm dosyalar
- ✅ `.gitignore`
- ✅ `README.md`
- ✅ `DEPLOYMENT.md`
- ✅ Tüm template dosyaları
- ✅ Tüm static dosyalar
- ✅ `core/` uygulaması

## 🚫 Eklenmemesi Gereken Dosyalar

- ❌ `.env` (güvenlik)
- ❌ `db.sqlite3` (development database)
- ❌ `venv/` (virtual environment)
- ❌ `media/` (yüklenen dosyalar)
- ❌ `__pycache__/` (Python cache)
- ❌ `*.pyc` (compiled Python)
- ❌ SSL sertifika dosyaları

## 🔄 Sunucuda Güncelleme

GitHub'a yükledikten sonra sunucuda:

```bash
cd /var/www/kutahyaaricilarbirligi

# Değişiklikleri çek
git pull origin main

# Log klasörünü oluştur
mkdir -p logs
chmod 755 logs

# Virtual environment'ı aktif et
source venv/bin/activate

# Gerekirse paketleri güncelle
pip install -r requirements.txt

# Django ayarlarını kontrol et
python manage.py check

# Migrate çalıştır
python manage.py migrate

# Static files topla
python manage.py collectstatic --noinput

# Gunicorn'u yeniden başlat
sudo systemctl restart gunicorn
```

## ⚠️ Önemli Notlar

1. **Secret Key**: Asla GitHub'a yüklenmemeli! `.env` dosyasında olmalı.
2. **Database Şifreleri**: Kodda olmamalı, `.env` dosyasında olmalı.
3. **SSL Sertifikaları**: GitHub'a yüklenmemeli, sunucuda manuel yüklenmeli.

## 🎯 Hızlı Komutlar (Windows PowerShell)

```powershell
cd C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi

# Durumu kontrol et
git status

# Tüm değişiklikleri ekle
git add .

# Commit yap
git commit -m "Production deployment: Tüm güncellemeler"

# Push et
git push origin main
```

## 📝 Commit Mesajı Örnekleri

```bash
# Kısa
git commit -m "Production deployment hazırlığı"

# Detaylı
git commit -m "Production deployment: Settings.py güncellemeleri, log klasörü düzeltmesi, database ayarları, SSL sertifika talimatları, deployment dokümantasyonu, requirements.txt güncellemesi (Django 4.2, Pillow 10.x)"

# Çok detaylı
git commit -m "Production deployment hazırlığı

- Settings.py: DEBUG ve SECRET_KEY güvenlik ayarları
- Log klasörü otomatik oluşturma
- Database ayarları environment variable desteği
- Requirements.txt: Django 4.2, Pillow 10.x (Python 3.8 uyumlu)
- SSL sertifika yükleme talimatları
- Detaylı deployment dokümantasyonu
- Nginx ve Gunicorn config dosyaları
- Sunucu IP ve domain ayarları"
```

