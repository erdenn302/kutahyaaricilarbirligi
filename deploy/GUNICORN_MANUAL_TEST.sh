#!/bin/bash
# Gunicorn Manuel Test - Hata Tespiti
# Kullanım: bash deploy/GUNICORN_MANUAL_TEST.sh

echo "🔍 Gunicorn Manuel Test - Hata Tespiti"
echo "======================================"
echo ""

cd /var/www/kutahyaaricilarbirligi
source venv/bin/activate

# 1. Django check
echo "🐍 [1/5] Django check:"
echo ""
python manage.py check 2>&1
DJANGO_CHECK_EXIT=$?

if [ $DJANGO_CHECK_EXIT -eq 0 ]; then
    echo ""
    echo "   ✅ Django check başarılı"
else
    echo ""
    echo "   ❌ Django check hatası!"
fi

# 2. Django import test
echo ""
echo "🐍 [2/5] Django import test:"
echo ""
python -c "
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kutahyaaricilarbirligi.settings')
try:
    django.setup()
    print('   ✅ Django setup başarılı')
except Exception as e:
    print(f'   ❌ Django setup hatası: {e}')
    import traceback
    traceback.print_exc()
" 2>&1

# 3. WSGI import test
echo ""
echo "🌐 [3/5] WSGI import test:"
echo ""
python -c "
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kutahyaaricilarbirligi.settings')
try:
    from kutahyaaricilarbirligi.wsgi import application
    print('   ✅ WSGI application import başarılı')
except Exception as e:
    print(f'   ❌ WSGI import hatası: {e}')
    import traceback
    traceback.print_exc()
" 2>&1

# 4. Gunicorn manuel test (tek worker)
echo ""
echo "🚀 [4/5] Gunicorn manuel test (tek worker, 5 saniye):"
echo ""
timeout 5 gunicorn kutahyaaricilarbirligi.wsgi:application \
    --bind 127.0.0.1:8000 \
    --workers 1 \
    --timeout 30 \
    --log-level debug \
    2>&1 | head -50 || true

# 5. Environment variables kontrolü
echo ""
echo "🔐 [5/5] Environment variables kontrolü:"
echo ""
if [ -f ".env" ]; then
    echo "   ✅ .env dosyası var"
    echo "   → SECRET_KEY: $(grep DJANGO_SECRET_KEY .env | cut -d= -f2 | cut -c1-20)..."
else
    echo "   ❌ .env dosyası yok!"
fi

echo ""
echo "======================================"
echo "📋 Özet:"
echo ""
echo "💡 Yukarıdaki hataları kontrol edin ve düzeltin."
echo ""

