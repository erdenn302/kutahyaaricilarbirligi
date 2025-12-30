#!/bin/bash
# CSR Oluşturma - Natro için 2048 bit
# Kullanım: bash deploy/CSR_NATRO_2048BIT.sh

echo "🔐 CSR Oluşturma - Natro için 2048 bit"
echo "======================================"
echo ""

# 1. Private key oluştur (2048 bit)
echo "🔑 [1/3] Private key oluşturuluyor (2048 bit)..."
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

# 2. CSR oluştur (interactive)
echo ""
echo "📝 [2/3] CSR oluşturuluyor..."
echo ""
echo "   ⚠️  Aşağıdaki bilgileri girmeniz gerekecek:"
echo "      - Country Name (Ülke): TR"
echo "      - State or Province Name (İl): Kütahya"
echo "      - Locality Name (Şehir): Kütahya"
echo "      - Organization Name (Kurum): Kütahya Arı Yetiştiricileri Birliği"
echo "      - Organizational Unit Name (Bölüm): IT (veya boş bırakın)"
echo "      - Common Name (Domain): kutahyaaricilarbirligi.com"
echo "      - Email Address: admin@kutahyaaricilarbirligi.com (veya boş bırakın)"
echo "      - Challenge password: (boş bırakın)"
echo "      - Optional company name: (boş bırakın)"
echo ""

# CSR oluştur (interactive)
sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key \
    -out /tmp/kutahyaaricilarbirligi.com.csr

if [ -f "/tmp/kutahyaaricilarbirligi.com.csr" ]; then
    echo ""
    echo "   ✅ CSR oluşturuldu: /tmp/kutahyaaricilarbirligi.com.csr"
else
    echo "   ❌ CSR oluşturulamadı!"
    exit 1
fi

# 3. CSR içeriğini göster
echo ""
echo "📋 [3/3] CSR içeriği:"
echo ""
echo "======================================"
cat /tmp/kutahyaaricilarbirligi.com.csr
echo "======================================"
echo ""

# CSR'i dosyaya kaydet (kopyalamak için)
echo "💾 CSR dosyası: /tmp/kutahyaaricilarbirligi.com.csr"
echo ""
echo "📋 Sonraki Adımlar:"
echo "   1. Yukarıdaki CSR içeriğini kopyalayın"
echo "   2. Natro panelinde 'CSR Yükle' bölümüne gidin"
echo "   3. CSR kodunu yapıştırın"
echo "   4. Sertifika onaylandıktan sonra indirin"
echo "   5. İndirdiğiniz sertifika dosyasını sunucuya yükleyin"
echo "   6. bash deploy/SSL_KURULUM_ADIM_ADIM.sh çalıştırın"
echo ""

