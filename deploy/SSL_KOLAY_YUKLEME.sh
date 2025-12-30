#!/bin/bash
# SSL Sertifikası Kolay Yükleme Scripti
# Kullanım: bash deploy/SSL_KOLAY_YUKLEME.sh

echo "🔒 SSL Sertifikası Yükleme Scripti"
echo "===================================="
echo ""

# Klasörleri oluştur
echo "📁 SSL klasörleri oluşturuluyor..."
sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private

# Kullanıcıdan dosya yollarını al
echo ""
echo "📝 Sertifika dosyalarınızın yolunu girin:"
echo "   Örnek: /tmp/kutahyaaricilarbirligi.com.crt"
read -p "Certificate dosyası (.crt veya .pem): " CERT_FILE

echo ""
echo "📝 Private key dosyanızın yolunu girin:"
echo "   Örnek: /tmp/kutahyaaricilarbirligi.com.key"
read -p "Private key dosyası (.key): " KEY_FILE

# Dosyaların varlığını kontrol et
if [ ! -f "$CERT_FILE" ]; then
    echo "❌ HATA: Certificate dosyası bulunamadı: $CERT_FILE"
    exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ HATA: Private key dosyası bulunamadı: $KEY_FILE"
    exit 1
fi

# Dosyaları kopyala
echo ""
echo "📋 Dosyalar kopyalanıyor..."
sudo cp "$CERT_FILE" /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo cp "$KEY_FILE" /etc/ssl/private/kutahyaaricilarbirligi.com.key

# İzinleri ayarla
echo "🔐 Dosya izinleri ayarlanıyor..."
sudo chmod 644 /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/certs/kutahyaaricilarbirligi.com.crt
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key

# Dosyaları kontrol et
echo ""
echo "✅ Dosyalar kontrol ediliyor..."
if [ -f "/etc/ssl/certs/kutahyaaricilarbirligi.com.crt" ] && [ -f "/etc/ssl/private/kutahyaaricilarbirligi.com.key" ]; then
    echo "✅ Dosyalar başarıyla yüklendi!"
    echo ""
    echo "📋 Dosya konumları:"
    echo "   Certificate: /etc/ssl/certs/kutahyaaricilarbirligi.com.crt"
    echo "   Private Key: /etc/ssl/private/kutahyaaricilarbirligi.com.key"
    echo ""
    echo "⚠️  ŞİMDİ YAPILACAKLAR:"
    echo "1. Nginx config dosyasını düzenleyin:"
    echo "   sudo nano /etc/nginx/sites-available/kutahyaaricilarbirligi"
    echo ""
    echo "2. Şu satırları bulun ve güncelleyin:"
    echo "   ssl_certificate /etc/ssl/certs/kutahyaaricilarbirligi.com.crt;"
    echo "   ssl_certificate_key /etc/ssl/private/kutahyaaricilarbirligi.com.key;"
    echo ""
    echo "3. Nginx'i test edin:"
    echo "   sudo nginx -t"
    echo ""
    echo "4. Nginx'i yeniden başlatın:"
    echo "   sudo systemctl reload nginx"
else
    echo "❌ HATA: Dosyalar yüklenemedi!"
    exit 1
fi

