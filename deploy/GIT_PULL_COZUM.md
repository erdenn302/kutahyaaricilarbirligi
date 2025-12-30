# 🔄 Git Pull Sorunu Çözümü

## ⚠️ Sorun

Sunucuda local değişiklikler var, git pull yapılamıyor.

## ✅ Çözüm: Stash ve Pull

### Seçenek 1: Local Değişiklikleri Stash Et (Önerilen)

```bash
cd /var/www/kutahyaaricilarbirligi

# Local değişiklikleri geçici olarak sakla
git stash

# Pull yap
git pull origin main

# Stash'i geri yükle (gerekirse)
# git stash pop
```

### Seçenek 2: Local Değişiklikleri Discard Et (Dikkatli!)

Eğer sunucudaki değişiklikler önemli değilse:

```bash
cd /var/www/kutahyaaricilarbirligi

# Local değişiklikleri at
git checkout -- kutahyaaricilarbirligi/settings.py requirements.txt

# Pull yap
git pull origin main
```

### Seçenek 3: Commit ve Pull (En Güvenli)

```bash
cd /var/www/kutahyaaricilarbirligi

# Değişiklikleri commit et
git add kutahyaaricilarbirligi/settings.py requirements.txt
git commit -m "Server: Local settings updates"

# Pull yap
git pull origin main

# Conflict varsa çöz
```

## 🎯 Önerilen: Stash Kullan

Sunucuda genelde local değişiklikler önemli değildir, stash kullanmak en pratik çözümdür.


