from django.shortcuts import render, get_object_or_404
from django.core.paginator import Paginator
from django.http import HttpResponse
from django.conf import settings
from .models import Haber, Duyuru, Proje, Baglanti, Hakkimizda, AricilikSayfasi, Mevzuat, MevzuatKategori, Kongre


def robots_txt(request):
    """robots.txt dosyasını serve eder"""
    robots_content = """User-agent: *
Allow: /

# Sitemap
Sitemap: https://www.kutahyaaricilarbirligi.com/sitemap.xml

# Admin paneli ve özel sayfalar
Disallow: /admin/
Disallow: /static/admin/

# Media dosyalarına izin ver
Allow: /media/
"""
    return HttpResponse(robots_content, content_type='text/plain')


def home(request):
    """
    Ana sayfa: Kütahya Arı Yetiştiricileri Birliği için kurumsal giriş sayfası.
    Son haberler ve duyuruları gösterir.
    """
    son_haberler = Haber.objects.filter(aktif=True)[:3]
    son_duyurular = Duyuru.objects.filter(aktif=True)[:3]
    
    context = {
        "page_title": "Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği resmi web sitesi. Arıcılık, bal üretimi, arı yetiştiriciliği, arıcılık takvimi ve arı ürünleri hakkında bilgiler.",
        "son_haberler": son_haberler,
        "son_duyurular": son_duyurular,
    }
    return render(request, "core/home.html", context)


def hakkimizda(request):
    """Hakkımızda sayfası"""
    hakkimizda_obj = Hakkimizda.objects.first()
    context = {
        "page_title": "Hakkımızda - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği hakkında bilgiler, misyonumuz, vizyonumuz ve faaliyetlerimiz.",
        "hakkimizda": hakkimizda_obj,
    }
    return render(request, "core/hakkimizda.html", context)


def haberler(request):
    """Haberler listesi"""
    haber_listesi = Haber.objects.filter(aktif=True).order_by('-yayin_tarihi')
    paginator = Paginator(haber_listesi, 9)
    page_number = request.GET.get('sayfa')
    haberler = paginator.get_page(page_number)
    
    context = {
        "page_title": "Haberler - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği güncel haberleri, arıcılık sektöründen son gelişmeler.",
        "haberler": haberler,
    }
    return render(request, "core/haberler.html", context)


def haber_detay(request, slug):
    """Haber detay sayfası"""
    haber = get_object_or_404(Haber, slug=slug, aktif=True)
    context = {
        "page_title": f"{haber.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": haber.ozet[:160] if len(haber.ozet) > 160 else haber.ozet,
        "haber": haber,
    }
    return render(request, "core/haber_detay.html", context)


def duyurular(request):
    """Duyurular listesi"""
    duyuru_listesi = Duyuru.objects.filter(aktif=True).order_by('-yayin_tarihi')
    paginator = Paginator(duyuru_listesi, 9)
    page_number = request.GET.get('sayfa')
    duyurular = paginator.get_page(page_number)
    
    context = {
        "page_title": "Duyurular - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği duyuruları, önemli bildirimler ve güncellemeler.",
        "duyurular": duyurular,
    }
    return render(request, "core/duyurular.html", context)


def duyuru_detay(request, slug):
    """Duyuru detay sayfası"""
    duyuru = get_object_or_404(Duyuru, slug=slug, aktif=True)
    context = {
        "page_title": f"{duyuru.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": duyuru.ozet[:160] if len(duyuru.ozet) > 160 else duyuru.ozet,
        "duyuru": duyuru,
    }
    return render(request, "core/duyuru_detay.html", context)


def projeler(request):
    """Projeler listesi"""
    proje_listesi = Proje.objects.filter(aktif=True).order_by('-baslangic_tarihi', 'sira')
    paginator = Paginator(proje_listesi, 9)
    page_number = request.GET.get('sayfa')
    projeler = paginator.get_page(page_number)
    
    context = {
        "page_title": "Projeler - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği projeleri, arı dostu projeler ve kırsal kalkınma programları.",
        "projeler": projeler,
    }
    return render(request, "core/projeler.html", context)


def proje_detay(request, slug):
    """Proje detay sayfası"""
    proje = get_object_or_404(Proje, slug=slug, aktif=True)
    context = {
        "page_title": f"{proje.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": proje.ozet[:160] if len(proje.ozet) > 160 else proje.ozet,
        "proje": proje,
    }
    return render(request, "core/proje_detay.html", context)


def aricilik(request):
    """Arıcılık sayfası"""
    aricilik_obj = AricilikSayfasi.objects.first()
    context = {
        "page_title": "Arıcılık - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Arıcılık teknikleri, arı ürünleri, arıcılık takvimi ve arı yetiştiriciliği hakkında detaylı bilgiler.",
        "aricilik": aricilik_obj,
    }
    return render(request, "core/aricilik.html", context)


def baglantilar(request):
    """Bağlantılar sayfası"""
    baglantilar = Baglanti.objects.filter(aktif=True).order_by('sira')
    context = {
        "page_title": "Bağlantılar - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Türkiye Arıcılar Birliği, Tarım Bakanlığı ve arıcılık sektörü ile ilgili önemli kuruluşların linkleri.",
        "baglantilar": baglantilar,
    }
    return render(request, "core/baglantilar.html", context)


def mevzuatlar(request):
    """Mevzuatlar sayfası - Kategorilere göre gruplandırılmış"""
    # URL'den kategori filtresi al
    kategori_filtre = request.GET.get('kategori', None)
    
    if kategori_filtre:
        # Belirli bir kategori göster
        try:
            kategori = MevzuatKategori.objects.get(ad=kategori_filtre, aktif=True)
            kategoriler = [kategori]
            mevzuatlar_dict = {}
            mevzuatlar = Mevzuat.objects.filter(kategori=kategori, aktif=True).order_by('sira', '-yayin_tarihi')
            if mevzuatlar.exists():
                mevzuatlar_dict[kategori] = mevzuatlar
        except MevzuatKategori.DoesNotExist:
            kategoriler = MevzuatKategori.objects.filter(aktif=True).order_by('sira', 'ad')
            mevzuatlar_dict = {}
    else:
        # Tüm kategorileri göster
        kategoriler = MevzuatKategori.objects.filter(aktif=True).order_by('sira', 'ad')
        mevzuatlar_dict = {}
        
        for kategori in kategoriler:
            mevzuatlar = Mevzuat.objects.filter(kategori=kategori, aktif=True).order_by('sira', '-yayin_tarihi')
            if mevzuatlar.exists():
                mevzuatlar_dict[kategori] = mevzuatlar
    
    context = {
        "page_title": "Mevzuatlar - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Arıcılık ile ilgili kanunlar, yönetmelikler, genelgeler, tebliğler, talimatnameler ve ana sözleşmeler.",
        "mevzuatlar_dict": mevzuatlar_dict,
        "aktif_kategori": kategori_filtre,
    }
    return render(request, "core/mevzuatlar.html", context)


def kongreler(request):
    """Kongreler listesi"""
    kongre_listesi = Kongre.objects.filter(aktif=True).order_by('-tarih', 'sira')
    paginator = Paginator(kongre_listesi, 9)
    page_number = request.GET.get('sayfa')
    kongreler = paginator.get_page(page_number)
    
    context = {
        "page_title": "Kongreler - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Arıcılık sektörü ile ilgili kongreler, sempozyumlar ve etkinlikler.",
        "kongreler": kongreler,
    }
    return render(request, "core/kongreler.html", context)


def kongre_detay(request, slug):
    """Kongre detay sayfası"""
    kongre = get_object_or_404(Kongre, slug=slug, aktif=True)
    context = {
        "page_title": f"{kongre.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": kongre.ozet[:160] if len(kongre.ozet) > 160 else kongre.ozet,
        "kongre": kongre,
    }
    return render(request, "core/kongre_detay.html", context)
