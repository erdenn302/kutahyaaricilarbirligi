#!/bin/bash
# SSL Tam Kurulum - Adım Adım Rehber
# Kullanım: bash deploy/SSL_TAM_KURULUM.sh

echo "🔐 SSL Tam Kurulum - Adım Adım"
echo "==============================="
echo ""

# 1. CSR oluşturma seçeneği
echo "📋 [1/3] CSR Oluşturma:"
echo ""
echo "   SSL sertifikası için önce CSR oluşturmanız gerekiyor."
echo ""
echo "   Seçenek 1: Interactive (önerilen)"
echo "      bash deploy/CSR_NATRO_2048BIT.sh"
echo ""
echo "   Seçenek 2: Non-Interactive (otomatik)"
echo "      bash deploy/CSR_NATRO_NON_INTERACTIVE.sh"
echo ""
read -p "   CSR oluşturmak istiyor musunuz? (e/h): " CREATE_CSR

if [ "$CREATE_CSR" = "e" ] || [ "$CREATE_CSR" = "E" ]; then
    echo ""
    echo "   Hangi yöntemi kullanmak istersiniz?"
    echo "   1) Interactive (sorular sorarak)"
    echo "   2) Non-Interactive (otomatik)"
    read -p "   Seçiminiz (1/2): " CSR_METHOD
    
    if [ "$CSR_METHOD" = "1" ]; then
        bash deploy/CSR_NATRO_2048BIT.sh
    elif [ "$CSR_METHOD" = "2" ]; then
        bash deploy/CSR_NATRO_NON_INTERACTIVE.sh
    else
        echo "   ⚠️  Geçersiz seçim, interactive kullanılıyor..."
        bash deploy/CSR_NATRO_2048BIT.sh
    fi
    
    echo ""
    echo "   ✅ CSR oluşturuldu!"
    echo ""
    echo "   📋 Sonraki Adımlar:"
    echo "      1. Yukarıdaki CSR içeriğini kopyalayın"
    echo "      2. Natro panelinde 'CSR Yükle' bölümüne gidin"
    echo "      3. CSR kodunu yapıştırın"
    echo "      4. Sertifika onaylandıktan sonra indirin"
    echo "      5. İndirdiğiniz sertifika dosyasını sunucuya yükleyin (/tmp klasörüne)"
    echo "      6. Bu script'i tekrar çalıştırın ve 'h' seçeneğini seçin"
    echo ""
    exit 0
fi

# 2. Sertifika dosyalarını kontrol et
echo ""
echo "📋 [2/3] Sertifika Dosyaları Kontrolü:"
echo ""

CERT_PATH="/etc/ssl/certs/kutahyaaricilarbirligi.com.crt"
KEY_PATH="/etc/ssl/private/kutahyaaricilarbirligi.com.key"

# /tmp'de sertifika var mı?
TMP_CERT=$(find /tmp -name "*.crt" -o -name "*.pem" -o -name "*.cer" 2>/dev/null | grep -i "kutahya\|cert" | head -1)
TMP_KEY=$(find /tmp -name "*.key" 2>/dev/null | grep -i "kutahya\|private" | head -1)

if [ -n "$TMP_CERT" ]; then
    echo "   ✅ /tmp klasöründe sertifika dosyası bulundu: $TMP_CERT"
    read -p "   Bu dosyayı kullanmak istiyor musunuz? (e/h): " USE_TMP_CERT
    if [ "$USE_TMP_CERT" = "e" ] || [ "$USE_TMP_CERT" = "E" ]; then
        echo "   → Sertifika dosyası taşınıyor..."
        sudo mkdir -p /etc/ssl/certs
        sudo cp "$TMP_CERT" "$CERT_PATH"
        sudo chmod 644 "$CERT_PATH"
        sudo chown root:root "$CERT_PATH"
        echo "   ✅ Sertifika dosyası taşındı: $CERT_PATH"
    fi
fi

if [ -n "$TMP_KEY" ]; then
    echo "   ✅ /tmp klasöründe key dosyası bulundu: $TMP_KEY"
    read -p "   Bu dosyayı kullanmak istiyor musunuz? (e/h): " USE_TMP_KEY
    if [ "$USE_TMP_KEY" = "e" ] || [ "$USE_TMP_KEY" = "E" ]; then
        echo "   → Key dosyası taşınıyor..."
        sudo mkdir -p /etc/ssl/private
        sudo cp "$TMP_KEY" "$KEY_PATH"
        sudo chmod 600 "$KEY_PATH"
        sudo chown root:root "$KEY_PATH"
        echo "   ✅ Key dosyası taşındı: $KEY_PATH"
    fi
fi

# Sertifika dosyaları var mı kontrol et
if [ ! -f "$CERT_PATH" ]; then
    echo ""
    echo "   ❌ Sertifika dosyası bulunamadı: $CERT_PATH"
    echo ""
    echo "   💡 Sertifika dosyasını yüklemeniz gerekiyor:"
    echo "      1. Sertifika dosyasını bilgisayarınızdan sunucuya yükleyin"
    echo "         - WinSCP/FileZilla ile /tmp klasörüne yükleyin"
    echo "         - VEYA SCP ile: scp sertifika.crt root@37.148.208.77:/tmp/"
    echo "      2. Bu script'i tekrar çalıştırın"
    echo ""
    exit 1
fi

if [ ! -f "$KEY_PATH" ]; then
    echo ""
    echo "   ❌ Private key dosyası bulunamadı: $KEY_PATH"
    echo ""
    echo "   💡 Private key dosyası zaten oluşturulmuş olmalı (CSR oluştururken)"
    echo "      Eğer yoksa, CSR oluşturma script'ini tekrar çalıştırın"
    echo ""
    exit 1
fi

echo ""
echo "   ✅ Sertifika dosyaları hazır!"

# 3. SSL kurulum script'ini çalıştır
echo ""
echo "📋 [3/3] SSL Kurulum Script'i Çalıştırılıyor..."
echo ""
read -p "   SSL kurulum script'ini çalıştırmak istiyor musunuz? (e/h): " RUN_SSL_INSTALL

if [ "$RUN_SSL_INSTALL" = "e" ] || [ "$RUN_SSL_INSTALL" = "E" ]; then
    bash deploy/SSL_KURULUM_ADIM_ADIM.sh
else
    echo ""
    echo "   ⚠️  SSL kurulum script'i çalıştırılmadı"
    echo "   → Manuel olarak çalıştırmak için: bash deploy/SSL_KURULUM_ADIM_ADIM.sh"
fi

echo ""
echo "======================================"
echo "✅ İşlem tamamlandı!"
echo ""
echo "🔍 Kontrol için:"
echo "   bash deploy/SSL_KONTROL.sh"
echo ""

