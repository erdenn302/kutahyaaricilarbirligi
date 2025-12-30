#!/bin/bash
# HTTP 500 Hata Detaylı Analiz
# Kullanım: bash deploy/500_HATA_DETAYLI.sh

echo "🔍 HTTP 500 Hata Detaylı Analiz"
echo "================================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Gunicorn log - son hatalar
echo "📋 [1/5] Gunicorn Log - Son Hatalar:"
echo ""
sudo journalctl -u gunicorn -n 100 --no-pager | grep -A 10 -i "error\|exception\|traceback" | tail -30

# 2. Django log
echo ""
echo "📋 [2/5] Django Log:"
if [ -f "logs/django.log" ]; then
    echo "   Son 50 satır:"
    tail -50 logs/django.log | grep -A 5 -i "error\|exception\|traceback" | tail -30
else
    echo "   ⚠️  Django log dosyası bulunamadı"
fi

# 3. DEBUG=True yaparak test
echo ""
echo "🐍 [3/5] DEBUG=True ile Test:"
echo "   → .env dosyasında DEBUG=True yapılıyor..."

# .env yedekle
cp .env .env.backup

# DEBUG=True yap
sed -i 's/^DEBUG=.*/DEBUG=True/' .env

# Gunicorn restart
sudo systemctl restart gunicorn
sleep 3

# Test
echo "   → Test ediliyor..."
TEST_RESPONSE=$(curl -s http://127.0.0.1:8000 2>&1 | head -50)

if echo "$TEST_RESPONSE" | grep -qi "traceback\|exception\|error"; then
    echo "   ⚠️  Hata detayları:"
    echo "$TEST_RESPONSE" | grep -A 20 -i "traceback\|exception" | head -30
else
    echo "   ✅ DEBUG=True ile site çalışıyor"
fi

# DEBUG=False'ye geri döndür
mv .env.backup .env
sudo systemctl restart gunicorn

# 4. Django check - detaylı
echo ""
echo "🐍 [4/5] Django Check - Detaylı:"
python manage.py check --deploy 2>&1 | head -30

# 5. Manuel Django test
echo ""
echo "🧪 [5/5] Manuel Django Test:"
echo "   → Django'yu manuel başlatıyoruz (5 saniye)..."
timeout 5 python manage.py runserver 0.0.0.0:8001 2>&1 | head -30 &
RUNSERVER_PID=$!
sleep 3
kill $RUNSERVER_PID 2>/dev/null || true
wait $RUNSERVER_PID 2>/dev/null || true

echo ""
echo "======================================"
echo "📋 Özet:"
echo ""
echo "💡 Yukarıdaki hata mesajlarını kontrol edin"
echo "   Özellikle 'Traceback' ile başlayan satırlar önemli"
echo ""

