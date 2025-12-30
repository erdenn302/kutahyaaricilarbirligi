#!/bin/bash
# Site Yayına Alma - Hızlı Script
# Kullanım: bash deploy/YAYINA_ALMA_HIZLI.sh

echo "🚀 Site Yayına Alma - Son Kontroller"
echo "======================================"
echo ""

cd /var/www/kutahyaaricilarbirligi

# 1. Static klasörünü oluştur
echo "📁 Static klasörü oluşturuluyor..."
mkdir -p static/css static/js static/images
chmod -R 755 static

# 2. Static files topla
echo "📦 Static files toplanıyor..."
source venv/bin/activate
python manage.py collectstatic --noinput
sudo chown -R www-data:www-data staticfiles

# 3. Gunicorn service kontrolü
echo "🔧 Gunicorn service kontrol ediliyor..."
if ! grep -q "EnvironmentFile" /etc/systemd/system/gunicorn.service; then
    echo "⚠️  Gunicorn service dosyasına EnvironmentFile ekleniyor..."
    sudo sed -i '/WorkingDirectory/a EnvironmentFile=/var/www/kutahyaaricilarbirligi/.env' /etc/systemd/system/gunicorn.service
    sudo systemctl daemon-reload
    sudo systemctl restart gunicorn
    echo "✅ Gunicorn service güncellendi!"
else
    echo "✅ Gunicorn service zaten güncelli."
fi

# 4. Servisleri kontrol et
echo ""
echo "🔍 Servis durumları kontrol ediliyor..."
echo ""

echo "📊 Nginx durumu:"
sudo systemctl is-active nginx && echo "✅ Nginx çalışıyor" || echo "❌ Nginx çalışmıyor"

echo ""
echo "📊 Gunicorn durumu:"
sudo systemctl is-active gunicorn && echo "✅ Gunicorn çalışıyor" || echo "❌ Gunicorn çalışmıyor"

# 5. Port kontrolü
echo ""
echo "🔌 Port kontrolü:"
if sudo netstat -tlnp 2>/dev/null | grep -q ":80"; then
    echo "✅ Port 80 açık (HTTP)"
else
    echo "❌ Port 80 kapalı"
fi

if sudo netstat -tlnp 2>/dev/null | grep -q ":8000"; then
    echo "✅ Port 8000 açık (Gunicorn)"
else
    echo "❌ Port 8000 kapalı"
fi

# 6. Site test
echo ""
echo "🌐 Site test ediliyor..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Site çalışıyor! (HTTP $HTTP_CODE)"
else
    echo "❌ Site çalışmıyor! (HTTP $HTTP_CODE)"
fi

echo ""
echo "======================================"
echo "✅ Kontroller tamamlandı!"
echo ""
echo "🌐 Site Adresleri:"
echo "   - Ana Sayfa: http://kutahyaaricilarbirligi.com"
echo "   - Admin Panel: http://kutahyaaricilarbirligi.com/admin/"
echo ""
echo "📝 Yapılacaklar:"
echo "   1. Admin panelinden içerik ekleyin"
echo "   2. Logo yükleyin (Site Ayarları)"
echo "   3. SSL sertifikası ekleyin (opsiyonel)"
echo ""

