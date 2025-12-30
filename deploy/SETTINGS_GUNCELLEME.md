# 🔄 Settings.py Sunucuda Güncelleme Yöntemleri

## Yöntem 1: GitHub'dan Çekme (Önerilen)

Eğer projeyi GitHub'a yüklediyseniz:

```bash
cd /var/www/kutahyaaricilarbirligi

# Değişiklikleri çek
git pull origin main
# veya
git pull origin master

# Virtual environment'ı aktif et
source venv/bin/activate

# Log klasörünü oluştur (eğer yoksa)
mkdir -p logs
chmod 755 logs
```

## Yöntem 2: SCP ile Dosya Yükleme (Windows'tan)

Windows PowerShell'de:

```powershell
# Settings.py dosyasını sunucuya yükle
scp C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi\kutahyaaricilarbirligi\settings.py root@37.148.208.77:/var/www/kutahyaaricilarbirligi/kutahyaaricilarbirligi/
```

## Yöntem 3: WinSCP/FileZilla ile Yükleme

1. **WinSCP** veya **FileZilla** programını açın
2. Sunucuya bağlanın:
   - **Host**: 37.148.208.77
   - **Kullanıcı**: root
   - **Şifre**: sunucu şifreniz
3. Sol tarafta (bilgisayarınız) `settings.py` dosyasını bulun
4. Sağ tarafta (sunucu) `/var/www/kutahyaaricilarbirligi/kutahyaaricilarbirligi/` klasörüne gidin
5. Dosyayı sürükleyip bırakın (üzerine yaz)

## Yöntem 4: Nano ile Manuel Düzenleme

Sunucuda:

```bash
cd /var/www/kutahyaaricilarbirligi
nano kutahyaaricilarbirligi/settings.py
```

Gerekli değişiklikleri yapın:
- Database ayarlarını düzeltin
- Log klasörü ayarlarını kontrol edin

**Nano kullanımı:**
- `Ctrl + O` → Kaydet
- `Enter` → Onayla
- `Ctrl + X` → Çık

## Yöntem 5: Tek Komutla Güncelleme (Database Ayarları)

Eğer sadece database ayarlarını güncellemek istiyorsanız:

```bash
cd /var/www/kutahyaaricilarbirligi

# Mevcut settings.py'yi yedekle
cp kutahyaaricilarbirligi/settings.py kutahyaaricilarbirligi/settings.py.backup

# Database ayarlarını direkt ekle (güvenlik için önerilmez ama hızlı)
cat >> kutahyaaricilarbirligi/settings.py << 'EOF'

# Direkt Database Ayarları (Production)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'kutahyaaricilarbirligi',
        'USER': 'kutahyaaricilarbirligi',
        'PASSWORD': 'GucluSifre_2025!',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
EOF
```

**NOT**: Bu yöntem dosyanın sonuna ekler, mevcut database ayarlarını değiştirmez. Manuel düzenleme gerekir.

## Güncelleme Sonrası

```bash
# Log klasörünü oluştur
mkdir -p logs
chmod 755 logs

# Virtual environment'ı aktif et
source venv/bin/activate

# Django ayarlarını kontrol et
python manage.py check

# Migrate çalıştır
python manage.py migrate
```

## Hızlı Komut (Hepsini Birden)

```bash
cd /var/www/kutahyaaricilarbirligi && \
mkdir -p logs && \
chmod 755 logs && \
source venv/bin/activate && \
python manage.py check && \
python manage.py migrate
```

## ⚠️ Önemli Notlar

1. **Yedek Alın**: Güncellemeden önce mevcut settings.py'yi yedekleyin:
   ```bash
   cp kutahyaaricilarbirligi/settings.py kutahyaaricilarbirligi/settings.py.backup
   ```

2. **Database Şifresi**: Production'da şifreleri direkt kodda tutmak güvenli değil. `.env` dosyası kullanın.

3. **Log Klasörü**: Mutlaka oluşturun:
   ```bash
   mkdir -p logs
   chmod 755 logs
   ```

## 🔍 Kontrol

Güncelleme sonrası kontrol edin:

```bash
# Django ayarlarını kontrol et
python manage.py check

# DEBUG durumunu kontrol et
python manage.py shell
>>> from django.conf import settings
>>> print(settings.DEBUG)
>>> print(settings.DATABASES['default']['NAME'])
>>> exit()
```

