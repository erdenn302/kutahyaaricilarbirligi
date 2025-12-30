# 🌐 Natro Server Tipi Seçimi

## 📋 Server Tipi Seçimi

Natro'da SSL sertifikası için server tipi seçerken:

### ✅ Doğru Seçim

**"Other" veya "Diğer" veya "Other/Diğer"** seçin

Nginx seçeneği yoksa, "Other" seçeneğini kullanın. CSR formatı tüm server tipleri için aynıdır.

### ❌ Yanlış Seçimler

- Apache (biz Nginx kullanıyoruz)
- IIS (Windows server, biz Linux kullanıyoruz)

## 🔐 CSR Oluşturma

Server tipi seçimi CSR formatını etkilemez. Hangi server tipini seçerseniz seçin, CSR aynı formatta oluşturulur.

### CSR Oluşturma Adımları

1. **Server Tipi**: "Other" veya "Diğer" seçin
2. **Bit Uzunluğu**: 2048 bit (Natro'nun istediği)
3. **CSR Oluştur**: Sunucuda script'i çalıştırın:
   ```bash
   bash deploy/CSR_NATRO_2048BIT.sh
   ```
4. **CSR'i Kopyala**: Oluşturulan CSR içeriğini kopyalayın
5. **Natro'ya Yükle**: CSR kodunu Natro panelinde yapıştırın

## 📝 Önemli Notlar

1. **Server Tipi Önemli Değil**: CSR formatı tüm server tipleri için aynıdır
2. **Bit Uzunluğu Önemli**: 2048 bit seçmelisiniz (Natro'nun istediği)
3. **CSR Formatı**: Standart PEM formatı (-----BEGIN CERTIFICATE REQUEST-----)

## ✅ Sonuç

Natro'da:
- **Server Tipi**: "Other" veya "Diğer" seçin
- **Bit Uzunluğu**: 2048 bit
- **CSR**: Sunucuda oluşturulan CSR'i yapıştırın

CSR oluşturma ve sertifika kurulumu aynı şekilde devam eder!

