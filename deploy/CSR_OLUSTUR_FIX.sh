#!/bin/bash
# CSR Oluşturma - Düzeltilmiş Versiyon

echo "🔐 CSR Oluşturuluyor..."

# Private key kontrolü
if [ ! -f "/etc/ssl/private/kutahyaaricilarbirligi.com.key" ]; then
    echo "❌ Private key bulunamadı! Önce private key oluşturun:"
    echo "   sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048"
    exit 1
fi

# CSR oluştur (Türkçe karakterler için tırnak kullan)
sudo openssl req -new \
    -key /etc/ssl/private/kutahyaaricilarbirligi.com.key \
    -out /tmp/kutahyaaricilarbirligi.com.csr \
    -subj "/C=TR/ST=Kutahya/L=Kutahya/O=Kutahya Aricilar Birligi/OU=IT/CN=kutahyaaricilarbirligi.com/emailAddress=admin@kutahyaaricilarbirligi.com"

# Dosya kontrolü
if [ -f "/tmp/kutahyaaricilarbirligi.com.csr" ]; then
    echo ""
    echo "✅ CSR başarıyla oluşturuldu!"
    echo ""
    echo "📄 CSR İçeriği:"
    echo "=========================================="
    cat /tmp/kutahyaaricilarbirligi.com.csr
    echo "=========================================="
    echo ""
    echo "📋 Dosya konumu: /tmp/kutahyaaricilarbirligi.com.csr"
else
    echo "❌ CSR oluşturulamadı!"
    exit 1
fi

