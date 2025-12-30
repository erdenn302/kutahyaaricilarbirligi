# 🔍 Sunucu IP Detaylı Kontrol

## 📡 Sunucu IP Adresini Kontrol Etme

### Komut 1: Ana IP Adresi

```bash
hostname -I
```

veya

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Komut 2: Tüm IP Adresleri

```bash
ip addr show
```

### Komut 3: Network Interface'ler

```bash
ifconfig
```

veya

```bash
ip link show
```

## 🌐 Nginx IP Binding Kontrolü

### Nginx Config Dosyasını Kontrol Et

```bash
sudo cat /etc/nginx/sites-available/kutahyaaricilarbirligi
```

**Önemli:** `listen 80;` satırı olmalı. Bu, Nginx'in tüm IP adreslerinde dinlemesi anlamına gelir.

Eğer sadece belirli bir IP'de dinlemek istiyorsanız:
```nginx
listen 37.148.208.77:80;
```

Ama genellikle tüm IP'lerde dinlemek daha iyidir:
```nginx
listen 80;
```

## 🔌 Port Kontrolü

### Hangi IP'lerde Port 80 Açık?

```bash
sudo netstat -tlnp | grep :80
```

veya

```bash
sudo ss -tlnp | grep :80
```

Çıktı şöyle olmalı:
```
tcp  0  0  0.0.0.0:80  0.0.0.0:*  LISTEN  1234/nginx
```

`0.0.0.0:80` = Tüm IP adreslerinde port 80 açık ✅

## 🌐 Site Test (IP ile)

### Local Test

```bash
curl -I http://localhost
curl -I http://127.0.0.1
```

### IP ile Test

```bash
# Sunucu IP'si ile
curl -I http://$(hostname -I | awk '{print $1}')

# Beklenen IP ile
curl -I http://37.148.208.77
```

### Dışarıdan Test (Yerel Bilgisayardan)

Tarayıcıda:
```
http://37.148.208.77
```

## 🔥 Firewall Kontrolü

### Firewall Durumu

```bash
sudo ufw status
```

### Port 80 Açık mı?

```bash
sudo ufw status | grep 80
```

### Port 80'i Aç

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

## 📋 Kontrol Listesi

- [ ] Sunucu IP adresi doğru mu? (`hostname -I`)
- [ ] Nginx port 80'de dinliyor mu? (`sudo netstat -tlnp | grep :80`)
- [ ] Nginx config'de `listen 80;` var mı?
- [ ] Gunicorn port 8000'de çalışıyor mu? (`sudo netstat -tlnp | grep :8000`)
- [ ] Firewall port 80'i açık mı? (`sudo ufw status`)
- [ ] IP ile site erişilebilir mi? (`curl -I http://37.148.208.77`)

## 🚀 Hızlı Kontrol Scripti

```bash
bash deploy/SUNUCU_IP_KONTROL.sh
```

## ❌ Sorun Giderme

### IP ile erişilemiyorsa:

1. **Nginx çalışıyor mu?**
   ```bash
   sudo systemctl status nginx
   ```

2. **Port 80 açık mı?**
   ```bash
   sudo netstat -tlnp | grep :80
   ```

3. **Firewall kontrolü**
   ```bash
   sudo ufw allow 80/tcp
   ```

4. **Nginx config kontrolü**
   ```bash
   sudo nginx -t
   sudo cat /etc/nginx/sites-available/kutahyaaricilarbirligi
   ```

### IP adresi farklıysa:

1. Sunucu sağlayıcınızdan IP adresini kontrol edin
2. Nginx config'de doğru IP'yi kullanın
3. DNS ayarlarını doğru IP ile güncelleyin

