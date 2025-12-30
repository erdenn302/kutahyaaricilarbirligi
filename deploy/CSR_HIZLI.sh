#!/bin/bash
# CSR Hızlı Oluşturma Scripti
# Kullanım: bash deploy/CSR_HIZLI.sh

echo "🔐 CSR (Certificate Signing Request) Oluşturma"
echo "================================================"
echo ""

# Klasörleri oluştur
sudo mkdir -p /etc/ssl/private
sudo mkdir -p /tmp

# Private key oluştur
echo "🔑 Private key oluşturuluyor (2048 bit)..."
sudo openssl genrsa -out /etc/ssl/private/kutahyaaricilarbirligi.com.key 2048
sudo chmod 600 /etc/ssl/private/kutahyaaricilarbirligi.com.key
sudo chown root:root /etc/ssl/private/kutahyaaricilarbirligi.com.key

echo "✅ Private key oluşturuldu: /etc/ssl/private/kutahyaaricilarbirligi.com.key"
echo ""

# Kullanıcıdan bilgileri al
echo "📝 Sertifika bilgilerini girin:"
echo ""

read -p "Ülke Kodu (2 harf) [TR]: " COUNTRY
COUNTRY=${COUNTRY:-TR}

read -p "İl/Şehir [Kütahya]: " STATE
STATE=${STATE:-Kütahya}

read -p "İlçe [Kütahya]: " CITY
CITY=${CITY:-Kütahya}

read -p "Kurum Adı [Kütahya Arı Yetiştiricileri Birliği]: " ORG
ORG=${ORG:-Kütahya Arı Yetiştiricileri Birliği}

read -p "Bölüm [IT]: " OU
OU=${OU:-IT}

read -p "Domain Adı (Common Name) [kutahyaaricilarbirligi.com]: " CN
CN=${CN:-kutahyaaricilarbirligi.com}

read -p "E-posta [admin@kutahyaaricilarbirligi.com]: " EMAIL
EMAIL=${EMAIL:-admin@kutahyaaricilarbirligi.com}

# CSR oluştur
echo ""
echo "📋 CSR oluşturuluyor..."
sudo openssl req -new -key /etc/ssl/private/kutahyaaricilarbirligi.com.key \
    -out /tmp/kutahyaaricilarbirligi.com.csr \
    -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$OU/CN=$CN/emailAddress=$EMAIL"

echo ""
echo "✅ CSR oluşturuldu: /tmp/kutahyaaricilarbirligi.com.csr"
echo ""
echo "📄 CSR İçeriği:"
echo "=========================================="
cat /tmp/kutahyaaricilarbirligi.com.csr
echo "=========================================="
echo ""
echo "📥 CSR Dosyasını İndirme:"
echo "   scp root@37.148.208.77:/tmp/kutahyaaricilarbirligi.com.csr ."
echo ""
echo "⚠️  ÖNEMLİ:"
echo "   1. Yukarıdaki CSR içeriğini kopyalayın"
echo "   2. Sertifika oluşturma formuna yapıştırın"
echo "   3. Private key'i ASLA paylaşmayın!"
echo "   4. Private key yedeklendi: /etc/ssl/private/kutahyaaricilarbirligi.com.key"


