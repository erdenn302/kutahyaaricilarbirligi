# 🚀 GitHub'a Push - Hazır Komutlar

## Windows PowerShell'de Çalıştırın

```powershell
cd C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi

# 1. Tüm değişiklikleri ekle
git add .

# 2. Durumu kontrol et
git status

# 3. Commit yap
git commit -m "Production deployment: Settings.py güncellemeleri, log klasörü düzeltmesi, database ayarları, SSL sertifika talimatları, deployment dokümantasyonu, requirements.txt güncellemesi (Django 4.2, Pillow 10.x)"

# 4. GitHub'a push et
git push origin main
```

## Detaylı Commit Mesajı (Opsiyonel)

```powershell
git commit -m "Production deployment hazırlığı

- Settings.py: DEBUG ve SECRET_KEY güvenlik ayarları, log klasörü otomatik oluşturma
- Database ayarları: Environment variable desteği
- Requirements.txt: Django 4.2, Pillow 10.x (Python 3.8 uyumlu)
- SSL sertifika yükleme talimatları ve scriptleri
- Detaylı deployment dokümantasyonu (DEPLOYMENT_DETAYLI.md)
- Nginx ve Gunicorn config dosyaları
- Sunucu IP (37.148.208.77) ve domain (kutahyaaricilarbirligi.com) ayarları
- Log klasörü hatası çözümü
- CSR oluşturma scriptleri ve talimatları
- Production settings kontrol dokümantasyonu"
```

## Eğer İlk Kez Push Ediyorsanız

```powershell
# Remote ekle (KULLANICIADI değiştirin)
git remote add origin https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git

# Branch'i main olarak ayarla
git branch -M main

# Push et
git push -u origin main
```

## Kontrol

Push sonrası GitHub'da kontrol edin:
- Tüm dosyalar yüklendi mi?
- `.env` dosyası yüklenmedi mi? (güvenlik)
- `venv/` klasörü yüklenmedi mi?
- `db.sqlite3` yüklenmedi mi?

