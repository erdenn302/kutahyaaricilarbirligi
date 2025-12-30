# 📤 GitHub'a Yükleme Talimatları

## 1. Git Kurulumu (Eğer yüklü değilse)

### Windows:
1. https://git-scm.com/download/win adresinden Git'i indirin
2. Kurulumu tamamlayın
3. PowerShell veya Command Prompt'u yeniden başlatın

### Kontrol:
```bash
git --version
```

## 2. GitHub Repository Oluşturma

1. GitHub'a giriş yapın: https://github.com
2. Sağ üstteki **"+"** butonuna tıklayın
3. **"New repository"** seçin
4. Repository adı: `kutahyaaricilarbirligi` (veya istediğiniz isim)
5. **Public** veya **Private** seçin
6. **"Create repository"** butonuna tıklayın

## 3. Projeyi GitHub'a Yükleme

### Terminal/Command Prompt'u açın ve proje klasörüne gidin:

```bash
```

### Git Repository'sini başlatın:

```bash
# Git repository'sini başlat
git init

# Tüm dosyaları ekle
git add .

# İlk commit
git commit -m "Initial commit: Kütahya Arı Yetiştiricileri Birliği web sitesi"

# GitHub repository'nizi ekleyin (KULLANICIADI ve REPO_ADI değiştirin)
git remote add origin https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git

# Ana branch'i main olarak ayarlayın
git branch -M main

# GitHub'a yükleyin
git push -u origin main
```

## 4. Önemli Notlar

### ⚠️ Güvenlik:
- `.env` dosyası `.gitignore`'da olduğu için yüklenmeyecek (güvenli)
- `db.sqlite3` dosyası yüklenmeyecek
- `venv/` klasörü yüklenmeyecek
- Secret key'ler GitHub'a yüklenmeyecek

### 📝 İlk Yüklemeden Sonra:

1. **Secret Key Oluşturun:**
   ```bash
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```
   Bu key'i `.env` dosyasında kullanın.

2. **Environment Variables:**
   Production sunucuda `.env` dosyası oluşturun ve güvenli bilgileri ekleyin.

## 5. Sonraki Güncellemeler

Projeyi güncelledikten sonra:

```bash
# Değişiklikleri kontrol et
git status

# Değişiklikleri ekle
git add .

# Commit yap
git commit -m "Açıklayıcı mesaj buraya"

# GitHub'a yükle
git push
```

## 6. Sunucuya İndirme (Production)

Sunucuda projeyi indirmek için:

```bash
cd /var/www
git clone https://github.com/KULLANICIADI/kutahyaaricilarbirligi.git
cd kutahyaaricilarbirligi
```

Sonra `DEPLOYMENT.md` dosyasındaki talimatları takip edin.

## 7. GitHub Actions (Opsiyonel)

`.github/workflows/deploy.yml` dosyası otomatik test için hazırlanmıştır.
GitHub Actions'ı aktif etmek için repository ayarlarından etkinleştirin.

---

**Not**: İlk yüklemede GitHub kullanıcı adı ve şifre isteyebilir. 
GitHub Personal Access Token kullanmanız önerilir (Settings > Developer settings > Personal access tokens).


