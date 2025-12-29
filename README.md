# 🐝 Kütahya Arı Yetiştiricileri Birliği Web Sitesi

Profesyonel Django tabanlı kurumsal web sitesi. `www.kutahyaaricilarbirligi.com` için hazırlanmıştır.

## ✨ Özellikler

- 🏠 **Kurumsal Sayfalar**: Hakkımızda, Projeler, Arıcılık bilgileri
- 📰 **Haberler & Duyurular**: Dinamik içerik yönetimi
- 📅 **Arıcılık Takvimi**: Açılış popup'ı ve detaylı takvim sayfası
- 🔗 **Bağlantılar**: Önemli kuruluş linkleri
- 🎨 **Modern Tasarım**: Bootstrap 5, responsive, profesyonel arayüz
- 📝 **Admin Panel**: Kullanıcı dostu içerik yönetimi (CKEditor)
- 🔒 **SSL Desteği**: Production-ready, güvenli deployment
- 🚀 **SEO Optimized**: Meta tags, sitemap, robots.txt

## 🛠️ Teknolojiler

- **Backend**: Django 5.2
- **Frontend**: Bootstrap 5, JavaScript
- **Database**: PostgreSQL (production), SQLite (development)
- **Web Server**: Gunicorn + Nginx
- **SSL**: Let's Encrypt
- **Rich Text Editor**: CKEditor

## 📦 Kurulum

### Geliştirme Ortamı

```bash
# Repository'yi klonlayın
git clone https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
cd kutahyaaricilarbirligi

# Virtual environment oluşturun
python -m venv venv

# Virtual environment'ı aktif edin
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# Veritabanı migrations
python manage.py migrate

# Superuser oluşturun
python manage.py createsuperuser

# İlk verileri yükleyin (opsiyonel)
python manage.py create_initial_data

# Development server'ı başlatın
python manage.py runserver
```

Site: http://127.0.0.1:8000/  
Admin: http://127.0.0.1:8000/admin/

### Production Deployment

Detaylı deployment talimatları için [DEPLOYMENT.md](DEPLOYMENT.md) dosyasına bakın.

**Hızlı Başlangıç:**

```bash
# Deployment script'i çalıştırın
bash deploy/deploy.sh
```

## 📁 Proje Yapısı

```
kutahyaaricilarbirligi/
├── core/                    # Ana uygulama
│   ├── models.py           # Veritabanı modelleri
│   ├── views.py            # View fonksiyonları
│   ├── admin.py            # Admin panel yapılandırması
│   └── templates/          # HTML şablonları
├── kutahyaaricilarbirligi/  # Django proje ayarları
│   ├── settings.py         # Development ayarları
│   └── settings_production.py  # Production ayarları
├── static/                  # Statik dosyalar (CSS, JS, images)
├── media/                   # Yüklenen dosyalar
├── templates/              # Global şablonlar
├── deploy/                 # Deployment dosyaları
│   ├── nginx.conf         # Nginx yapılandırması
│   ├── gunicorn.service    # Systemd service dosyası
│   └── deploy.sh           # Otomatik deployment script
├── requirements.txt        # Python bağımlılıkları
└── DEPLOYMENT.md           # Detaylı deployment dokümantasyonu
```

## 🔐 Güvenlik

- ✅ SSL/HTTPS zorunlu (production)
- ✅ CSRF koruması
- ✅ XSS koruması
- ✅ SQL injection koruması
- ✅ Güvenli cookie ayarları
- ✅ HSTS headers

## 📝 Environment Variables

Production için `.env` dosyası oluşturun:

```env
DJANGO_SECRET_KEY=your-secret-key-here
DB_NAME=kutahyaaricilarbirligi
DB_USER=kutahyaaricilarbirligi
DB_PASSWORD=secure-password
DB_HOST=localhost
DB_PORT=5432
DEBUG=False
ALLOWED_HOSTS=www.kutahyaaricilarbirligi.com,kutahyaaricilarbirligi.com
```

## 🎯 Kullanım

### Admin Panel

1. Admin paneline giriş yapın: `/admin/`
2. **Site Ayarları**: Logo, iletişim bilgileri, sosyal medya linkleri
3. **Haberler & Duyurular**: İçerik ekleyin, düzenleyin
4. **Projeler**: Proje bilgilerini yönetin
5. **Bağlantılar**: Önemli kuruluş linklerini ekleyin

### Logo Ekleme

1. Logo dosyasını `static/images/logo.png` olarak ekleyin
2. Veya admin panelinden **Site Ayarları > Logo** bölümünden yükleyin
3. Logo otomatik olarak navbar'da ve arka plan pattern'inde görünecektir

## 🔄 Güncelleme

```bash
git pull
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart gunicorn
```

## 📞 Destek

Sorunlar için:
- GitHub Issues: [Issues sayfası](https://github.com/KULLANICIADI/kutahyaaricilarbirligi/issues)
- Log dosyaları: `/var/www/kutahyaaricilarbirligi/logs/`

## 📄 Lisans

Bu proje Kütahya Arı Yetiştiricileri Birliği için özel olarak geliştirilmiştir.

## 🙏 Teşekkürler

Tasarımda esinlenilen siteler:
- [Türkiye Arı Yetiştiricileri Merkez Birliği](https://tab.org.tr/)
- [İstanbul Arıcılar Birliği](https://www.istanbularicilarbirligi.com/)

---

**Geliştirici Notları**: Detaylı işlem logları için `yaptigimiz_islemler.txt` dosyasına bakın.
