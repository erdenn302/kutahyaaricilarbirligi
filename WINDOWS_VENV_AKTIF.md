# 🪟 Windows'ta Virtual Environment Aktif Etme

## ⚠️ Sorun

Virtual environment aktif değil, bu yüzden Django bulunamıyor.

## 🔧 Çözüm

### PowerShell'de:

```powershell
# Virtual environment'ı aktif et
.\venv\Scripts\Activate.ps1

# Eğer hata alırsanız (execution policy):
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Sonra tekrar deneyin
.\venv\Scripts\Activate.ps1

# Şimdi collectstatic çalıştır
python manage.py collectstatic --noinput
```

### Command Prompt'da:

```cmd
# Virtual environment'ı aktif et
venv\Scripts\activate.bat

# Şimdi collectstatic çalıştır
python manage.py collectstatic --noinput
```

## ✅ Kontrol

Virtual environment aktif olduğunda prompt şu şekilde görünür:
```
(venv) PS C:\Users\olc.atolye1\Documents\kutahyaaricilarbirligi>
```

## 🚀 Hızlı Komut (PowerShell)

```powershell
.\venv\Scripts\Activate.ps1; python manage.py collectstatic --noinput
```

