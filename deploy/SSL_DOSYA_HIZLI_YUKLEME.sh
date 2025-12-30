#!/bin/bash
# SSL Sertifika Dosyası Hızlı Yükleme
# Kullanım: bash deploy/SSL_DOSYA_HIZLI_YUKLEME.sh

echo "🔐 SSL Sertifika Dosyası Hızlı Yükleme"
echo "======================================"
echo ""

# /tmp klasöründe sertifika dosyası ara
echo "📋 [1/4] Sertifika dosyası aranıyor..."
echo ""

TMP_CERT=$(find /tmp -name "*.crt" -o -name "*.pem" -o -name "*.cer" 2>/dev/null | grep -i "kutahya\|cert" | head -1)

if [ -z "$TMP_CERT" ]; then
    # Tüm .crt, .pem, .cer dosyalarını listele
    echo "   ⚠️  /tmp klasöründe sertifika dosyası bulunamadı"
    echo ""
    echo "   📁 /tmp klasöründeki dosyalar:"
    ls -lh /tmp/*.{crt,pem,cer} 2>/dev/null | head -10 || echo "      Dosya bulunamadı"
    echo ""
    echo "   💡 Sertifika dosyasını /tmp klasörüne yükleyin:"
    echo "      - WinSCP/FileZilla ile /tmp klasörüne yükleyin"
    echo "      - VEYA SCP ile: scp sertifika.crt root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.crt"
    echo ""
    read -p "   Dosyayı yükledikten sonra devam etmek için Enter'a basın..."
    
    # Tekrar ara
    TMP_CERT=$(find /tmp -name "*.crt" -o -name "*.pem" -o -name "*.cer" 2>/dev/null | grep -i "kutahya\|cert" | head -1)
    
    if [ -z "$TMP_CERT" ]; then
        # Tüm sertifika dosyalarını listele
        ALL_CERTS=$(find /tmp -name "*.crt" -o -name "*.pem" -o -name "*.cer" 2>/dev/null | head -5)
        if [ -n "$ALL_CERTS" ]; then
            echo ""
            echo "   📁 Bulunan sertifika dosyaları:"
            echo "$ALL_CERTS" | while read CERT; do
                echo "      - $CERT"
            done
            echo ""
            read -p "   Hangi dosyayı kullanmak istersiniz? (tam yol): " SELECTED_CERT
            if [ -f "$SELECTED_CERT" ]; then
                TMP_CERT="$SELECTED_CERT"
            else
                echo "   ❌ Dosya bulunamadı!"
                exit 1
            fi
        else
            echo "   ❌ Hala sertifika dosyası bulunamadı!"
            exit 1
        fi
    fi
fi

echo "   ✅ Sertifika dosyası bulundu: $TMP_CERT"
ls -lh "$TMP_CERT"

# 2. Sertifika dosyasını taşı
echo ""
echo "📦 [2/4] Sertifika dosyası taşınıyor..."
CERT_PATH="/etc/ssl/certs/kutahyaaricilarbirligi.com.crt"

sudo mkdir -p /etc/ssl/certs
sudo cp "$TMP_CERT" "$CERT_PATH"
sudo chmod 644 "$CERT_PATH"
sudo chown root:root "$CERT_PATH"

if [ -f "$CERT_PATH" ]; then
    echo "   ✅ Sertifika dosyası taşındı: $CERT_PATH"
    ls -lh "$CERT_PATH"
else
    echo "   ❌ Sertifika dosyası taşınamadı!"
    exit 1
fi

# 3. Private key kontrolü
echo ""
echo "🔑 [3/4] Private key kontrolü..."
KEY_PATH="/etc/ssl/private/kutahyaaricilarbirligi.com.key"

if [ -f "$KEY_PATH" ]; then
    echo "   ✅ Private key var: $KEY_PATH"
    ls -lh "$KEY_PATH"
else
    echo "   ❌ Private key bulunamadı: $KEY_PATH"
    echo ""
    echo "   💡 Private key CSR oluştururken oluşturulmuş olmalı"
    echo "   → Eğer yoksa: bash deploy/CSR_NATRO_2048BIT.sh çalıştırın"
    exit 1
fi

# 4. SSL kurulum script'ini çalıştır
echo ""
echo "🚀 [4/4] SSL kurulum script'i çalıştırılıyor..."
echo ""

read -p "   SSL kurulum script'ini çalıştırmak istiyor musunuz? (e/h): " RUN_INSTALL

if [ "$RUN_INSTALL" = "e" ] || [ "$RUN_INSTALL" = "E" ]; then
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

