# 📝 Requirements.txt Güncelleme Yöntemleri

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

# Yeni requirements.txt ile paketleri güncelle
pip install --upgrade pip
pip install -r requirements.txt
```

## Yöntem 2: Manuel Güncelleme (Nano ile)

```bash
cd /var/www/kutahyaaricilarbirligi

# Dosyayı düzenle
nano requirements.txt
```

Dosya içeriği şu şekilde olmalı:

```
Django>=4.2,<5.0
gunicorn>=23.0.0
whitenoise>=6.7.0
psycopg2-binary>=2.9.10
Pillow>=10.0.0,<11.0.0
django-ckeditor
```

**Nano kullanımı:**
- Düzenleme yapın
- `Ctrl + O` ile kaydedin
- `Enter` ile onaylayın
- `Ctrl + X` ile çıkın

## Yöntem 3: Echo ile Hızlı Güncelleme

```bash
cd /var/www/kutahyaaricilarbirligi

# Dosyayı yeniden oluştur
cat > requirements.txt << 'EOF'
Django>=4.2,<5.0
gunicorn>=23.0.0
whitenoise>=6.7.0
psycopg2-binary>=2.9.10
Pillow>=10.0.0,<11.0.0
django-ckeditor
EOF
```

## Yöntem 4: SCP ile Dosya Yükleme (Windows'tan)

Windows bilgisayarınızdan sunucuya dosyayı yükleyin:

```bash
# Windows PowerShell veya Command Prompt'ta
scp requirements.txt root@37.148.208.77:/var/www/kutahyaaricilarbirligi/
```

## Yöntem 5: FTP/SFTP ile Yükleme

FileZilla veya WinSCP gibi bir FTP client kullanarak:
1. Sunucuya bağlanın
2. `/var/www/kutahyaaricilarbirligi/` dizinine gidin
3. `requirements.txt` dosyasını yükleyin

## Güncelleme Sonrası

Dosyayı güncelledikten sonra:

```bash
# Virtual environment'ı aktif et
source venv/bin/activate

# Pip'i güncelle
pip install --upgrade pip

# Paketleri yükle/güncelle
pip install -r requirements.txt

# Kurulumu kontrol et
pip list
python manage.py --version
```

## Hızlı Komut (Tümünü Birden)

```bash
cd /var/www/kutahyaaricilarbirligi && \
source venv/bin/activate && \
pip install --upgrade pip && \
pip install -r requirements.txt
```

## Sorun Giderme

### Eğer hala Django 5.0 hatası alıyorsanız:

```bash
# Mevcut Django'yu kaldır
pip uninstall django -y

# Django 4.2'yi manuel kur
pip install "Django>=4.2,<5.0"

# Diğer paketleri kur
pip install -r requirements.txt
```

### Cache temizleme:

```bash
pip cache purge
pip install --no-cache-dir -r requirements.txt
```

