#!/bin/bash
# CSR Oluşturma - Natro için 2048 bit (Non-Interactive)
# Kullanım: bash deploy/CSR_NATRO_NON_INTERACTIVE.sh

echo "🔐 CSR Oluşturma - Natro için 2048 bit (Non-Interactive)"
echo "========================================================="
echo ""

# 1. Private key oluştur (2048 bit)
echo "🔑 [1/2] Private key oluşturuluyor (2048 bit)..."
sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048

if [ -f "/etc/ssl/private/kutahyaaricilarbirligi.com.key" ]; then
    echo "   ✅ Private key oluşturuldu: /etc/ssl/private/kutahyaaricilarbirligi.com.key"
    
    # İzinleri ayarla
    sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
    sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key
    echo "   ✅ İzinler ayarlandı (600)"
else
    echo "   ❌ Private key oluşturulamadı!"
    exit 1
fi

# 2. CSR oluştur (non-interactive - ASCII karakterlerle)
echo ""
echo "📝 [2/2] CSR oluşturuluyor (non-interactive)..."
echo ""

sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key \
    -out /tmp/kutahyaaricilarbirligi.com.csr \
    -subj "/C=TR/ST=Kutahya/L=Kutahya/O=Kutahya Ari Yetistiricileri Birligi/OU=IT/CN=kutahyaaricilarbirligi.com/emailAddress=admin@kutahyaaricilarbirligi.com"

if [ -f "/tmp/kutahyaaricilarbirligi.com.csr" ]; then
    echo "   ✅ CSR oluşturuldu: /tmp/kutahyaaricilarbirligi.com.csr"
else
    echo "   ❌ CSR oluşturulamadı!"
    exit 1
fi

# 3. CSR içeriğini göster
echo ""
echo "📋 CSR içeriği:"
echo ""
echo "======================================"
cat /tmp/kutahyaaricilarbirligi.com.csr
echo "======================================"
echo ""

# CSR'i dosyaya kaydet (kopyalamak için)
echo "💾 CSR dosyası: /tmp/kutahyaaricilarbirligi.com.csr"
echo ""
echo "📋 Sonraki Adımlar:"
echo "   1. Yukarıdaki CSR içeriğini kopyalayın (-----BEGIN CERTIFICATE REQUEST----- ile başlayan)"
echo "   2. Natro panelinde 'CSR Yükle' bölümüne gidin"
echo "   3. CSR kodunu yapıştırın"
echo "   4. Sertifika onaylandıktan sonra indirin"
echo "   5. İndirdiğiniz sertifika dosyasını sunucuya yükleyin"
echo "   6. bash deploy/SSL_KURULUM_ADIM_ADIM.sh çalıştırın"
echo ""

