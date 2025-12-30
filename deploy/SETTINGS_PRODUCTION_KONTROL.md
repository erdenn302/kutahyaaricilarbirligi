# ⚙️ Settings.py Production Kontrol Listesi

## ✅ Mevcut Durum

`settings.py` dosyanız production için **hazır** ama birkaç önemli nokta var:

### 1. Environment Variables (.env dosyası)

**MUTLAKA** sunucuda `.env` dosyası oluşturun:

```bash
cd /var/www/kutahyaaricilarbirligi
nano .env
```

**İçeriği:**

```env
# GÜVENLİK - MUTLAKA AYARLAYIN!
DJANGO_SECRET_KEY=GÜVENLİ_SECRET_KEY_BURAYA
DEBUG=False

# Database
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=GÜVENLİ_ŞİFRE_BURAYA
DB_HOST=localhost
DB_PORT=5432

# Allowed Hosts
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com,37.148.208.77
```

### 2. Secret Key Oluşturma

```bash
source venv/bin/activate
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Bu komutun çıktısını `.env` dosyasındaki `DJANGO_SECRET_KEY` değerine yazın.

### 3. Production Kontrolü

Settings.py dosyası şu şekilde çalışıyor:

- ✅ **DEBUG**: `.env` dosyasında `DEBUG=False` olmalı
- ✅ **SECRET_KEY**: `.env` dosyasında `DJANGO_SECRET_KEY` olmalı
- ✅ **ALLOWED_HOSTS**: Sunucu IP ve domain'ler eklendi
- ✅ **Database**: Environment variable varsa PostgreSQL, yoksa SQLite (development)
- ✅ **Security Settings**: DEBUG=False olduğunda otomatik aktif

## 🔒 Güvenlik Ayarları

Production'da (`DEBUG=False`) otomatik olarak aktif olan ayarlar:

- ✅ `SECURE_SSL_REDIRECT = True` - HTTP'den HTTPS'e yönlendirme
- ✅ `SESSION_COOKIE_SECURE = True` - Cookie'ler sadece HTTPS'de
- ✅ `CSRF_COOKIE_SECURE = True` - CSRF cookie'leri güvenli
- ✅ `SECURE_HSTS_SECONDS = 31536000` - HSTS header (1 yıl)
- ✅ `X_FRAME_OPTIONS = 'DENY'` - Clickjacking koruması

## 📝 Sunucuda Yapılacaklar

### 1. .env Dosyası Oluştur

```bash
cd /var/www/kutahyaaricilarbirligi
nano .env
```

Yukarıdaki içeriği yapıştırın ve değerleri doldurun.

### 2. Secret Key Oluştur

```bash
source venv/bin/activate
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Çıkan key'i `.env` dosyasına kopyalayın.

### 3. Test Et

```bash
# Environment variables'ı yükle (opsiyonel, Django otomatik okur)
source venv/bin/activate

# Django ayarlarını kontrol et
python manage.py check --deploy

# DEBUG durumunu kontrol et
python manage.py shell
>>> from django.conf import settings
>>> print(settings.DEBUG)  # False olmalı
>>> print(settings.SECRET_KEY[:10])  # Secret key'in ilk 10 karakteri
>>> exit()
```

## ⚠️ ÖNEMLİ UYARILAR

1. **DEBUG=False**: Production'da mutlaka `False` olmalı!
2. **SECRET_KEY**: Asla GitHub'a yüklenmemeli, sadece `.env` dosyasında olmalı
3. **.env dosyası**: `.gitignore`'da olduğu için GitHub'a yüklenmeyecek (güvenli)
4. **Database şifresi**: Güçlü bir şifre kullanın

## ✅ Kontrol Listesi

- [ ] `.env` dosyası oluşturuldu
- [ ] `DJANGO_SECRET_KEY` ayarlandı (güçlü bir key)
- [ ] `DEBUG=False` ayarlandı
- [ ] Database bilgileri doğru
- [ ] `ALLOWED_HOSTS` doğru domain'leri içeriyor
- [ ] `python manage.py check --deploy` hatasız çalışıyor

## 🚀 Production'da Kullanım

Gunicorn başlatırken environment variables otomatik olarak okunur. Ekstra bir şey yapmanıza gerek yok.

Eğer manuel test ediyorsanız:

```bash
export DJANGO_SETTINGS_MODULE=kutahyaaricilarbirligi.settings
python manage.py runserver  # Sadece test için, production'da Gunicorn kullanın
```


