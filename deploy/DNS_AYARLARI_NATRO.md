# 🌐 DNS Ayarları - Natro Domain Yönlendirme

## ⚠️ Sorun

Domain `kutahyaaricilarbirligi.com` Natro'nun varsayılan sayfasına yönlendiriyor. Bu, DNS ayarlarının henüz yapılmadığı anlamına gelir.

## ✅ Çözüm: DNS A Kayıtları Ekleme

### ADIM 1: Natro Yönetim Paneline Giriş

1. https://www.natro.com adresine gidin
2. Müşteri Paneli'ne giriş yapın
3. Domain yönetim bölümüne gidin

### ADIM 2: DNS Ayarlarını Bulun

1. `kutahyaaricilarbirligi.com` domain'ini seçin
2. "DNS Yönetimi" veya "DNS Ayarları" bölümüne gidin
3. "A Kayıtları" veya "DNS Kayıtları" sekmesine tıklayın

### ADIM 3: A Kayıtları Ekleyin

Şu A kayıtlarını ekleyin:

#### Kayıt 1: Ana Domain
- **Tip:** A
- **Host/Name:** `@` veya boş bırakın
- **Value/IP:** `37.148.208.77`
- **TTL:** `3600` (veya varsayılan)

#### Kayıt 2: www Subdomain
- **Tip:** A
- **Host/Name:** `www`
- **Value/IP:** `37.148.208.77`
- **TTL:** `3600` (veya varsayılan)

### ADIM 4: Mevcut Kayıtları Kontrol Edin

Eğer şu kayıtlar varsa, **SİLİN veya DEĞİŞTİRİN:**
- `@` → `37.148.208.77` olmalı (Natro IP'si değil!)
- `www` → `37.148.208.77` olmalı

### ADIM 5: Kaydet ve Bekle

1. Değişiklikleri kaydedin
2. **DNS yayılımı 5 dakika - 48 saat sürebilir** (genellikle 15-30 dakika)
3. Beklerken IP ile test edin: `http://37.148.208.77`

## 🔍 DNS Yayılımını Kontrol Etme

### Sunucuda Test:

```bash
# DNS kontrolü
nslookup kutahyaaricilarbirligi.com
dig kutahyaaricilarbirligi.com

# IP adresi 37.148.208.77 olmalı
```

### Yerel Bilgisayarda Test:

```bash
# Windows PowerShell
nslookup kutahyaaricilarbirligi.com

# Linux/Mac
dig kutahyaaricilarbirligi.com
nslookup kutahyaaricilarbirligi.com
```

### Online DNS Kontrol:

- https://www.whatsmydns.net/#A/kutahyaaricilarbirligi.com
- https://dnschecker.org/#A/kutahyaaricilarbirligi.com

## ⏱️ DNS Yayılım Süresi

- **Minimum:** 5-15 dakika
- **Ortalama:** 30 dakika - 2 saat
- **Maksimum:** 48 saat

## 🚀 Beklerken Ne Yapabilirsiniz?

1. **IP ile test edin:** `http://37.148.208.77`
2. **Site içeriğini kontrol edin:** Admin panelinden içerik ekleyin
3. **Static files kontrolü:** `python manage.py collectstatic --noinput`

## ✅ DNS Yayılımı Tamamlandığında

1. Tarayıcıda `http://kutahyaaricilarbirligi.com` adresini açın
2. Site görünmeli!
3. Hard refresh yapın: `Ctrl + F5`

## 📝 Natro DNS Ayarları Örnek Görünüm

```
Tip    Host    Value           TTL
A      @       37.148.208.77   3600
A      www     37.148.208.77   3600
```

## ❌ Sorun Giderme

### DNS hala yayılmadıysa:

1. **TTL değerini düşürün:** 300 veya 600
2. **DNS cache temizleyin:**
   - Windows: `ipconfig /flushdns`
   - Linux: `sudo systemd-resolve --flush-caches`
   - Mac: `sudo dscacheutil -flushcache`
3. **Farklı DNS sunucusu kullanın:** Google DNS (8.8.8.8) veya Cloudflare (1.1.1.1)

### Hala Natro sayfası görünüyorsa:

1. DNS ayarlarını tekrar kontrol edin
2. Natro'da "Park Sayfası" veya "Varsayılan Sayfa" özelliğini kapatın
3. DNS yayılımının tamamlanmasını bekleyin

