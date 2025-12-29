from django.shortcuts import render, get_object_or_404
from django.core.paginator import Paginator
from .models import Haber, Duyuru, Proje, Baglanti, Hakkimizda, AricilikSayfasi


def home(request):
    """
    Ana sayfa: Kütahya Arı Yetiştiricileri Birliği için kurumsal giriş sayfası.
    Son haberler ve duyuruları gösterir.
    """
    son_haberler = Haber.objects.filter(aktif=True)[:3]
    son_duyurular = Duyuru.objects.filter(aktif=True)[:3]
    
    context = {
        "page_title": "Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği resmi web sitesi. "
        "Kütahya'da arıcılık faaliyetleri, eğitimler, projeler, haberler ve duyurular.",
        "son_haberler": son_haberler,
        "son_duyurular": son_duyurular,
    }
    return render(request, "core/home.html", context)


def hakkimizda(request):
    """Hakkımızda sayfası"""
    hakkimizda_obj = Hakkimizda.objects.first()
    if not hakkimizda_obj:
        hakkimizda_obj = Hakkimizda.objects.create(
            baslik="Hakkımızda",
            icerik="Kütahya Arı Yetiştiricileri Birliği hakkında bilgiler buraya eklenecektir."
        )
    
    context = {
        "page_title": "Hakkımızda - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği hakkında bilgiler.",
        "hakkimizda": hakkimizda_obj,
    }
    return render(request, "core/hakkimizda.html", context)


def haberler(request):
    """Haberler listesi"""
    haber_listesi = Haber.objects.filter(aktif=True)
    paginator = Paginator(haber_listesi, 10)
    page_number = request.GET.get('sayfa')
    haberler = paginator.get_page(page_number)
    
    context = {
        "page_title": "Haberler - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği haberleri ve güncel gelişmeler.",
        "haberler": haberler,
    }
    return render(request, "core/haberler.html", context)


def haber_detay(request, slug):
    """Haber detay sayfası"""
    haber = get_object_or_404(Haber, slug=slug, aktif=True)
    diger_haberler = Haber.objects.filter(aktif=True).exclude(id=haber.id)[:3]
    
    context = {
        "page_title": f"{haber.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": haber.ozet,
        "haber": haber,
        "diger_haberler": diger_haberler,
    }
    return render(request, "core/haber_detay.html", context)


def duyurular(request):
    """Duyurular listesi"""
    duyuru_listesi = Duyuru.objects.filter(aktif=True)
    paginator = Paginator(duyuru_listesi, 10)
    page_number = request.GET.get('sayfa')
    duyurular = paginator.get_page(page_number)
    
    context = {
        "page_title": "Duyurular - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği duyuruları ve önemli bilgilendirmeler.",
        "duyurular": duyurular,
    }
    return render(request, "core/duyurular.html", context)


def duyuru_detay(request, slug):
    """Duyuru detay sayfası"""
    duyuru = get_object_or_404(Duyuru, slug=slug, aktif=True)
    diger_duyurular = Duyuru.objects.filter(aktif=True).exclude(id=duyuru.id)[:3]
    
    context = {
        "page_title": f"{duyuru.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": duyuru.ozet,
        "duyuru": duyuru,
        "diger_duyurular": diger_duyurular,
    }
    return render(request, "core/duyuru_detay.html", context)


def projeler(request):
    """Projeler listesi"""
    proje_listesi = Proje.objects.filter(aktif=True)
    paginator = Paginator(proje_listesi, 10)
    page_number = request.GET.get('sayfa')
    projeler = paginator.get_page(page_number)
    
    context = {
        "page_title": "Projeler - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği projeleri ve faaliyetleri.",
        "projeler": projeler,
    }
    return render(request, "core/projeler.html", context)


def proje_detay(request, slug):
    """Proje detay sayfası"""
    proje = get_object_or_404(Proje, slug=slug, aktif=True)
    diger_projeler = Proje.objects.filter(aktif=True).exclude(id=proje.id)[:3]
    
    context = {
        "page_title": f"{proje.baslik} - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": proje.ozet,
        "proje": proje,
        "diger_projeler": diger_projeler,
    }
    return render(request, "core/proje_detay.html", context)


def aricilik(request):
    """Arıcılık sayfası"""
    aricilik_obj = AricilikSayfasi.objects.first()
    if not aricilik_obj:
        aricilik_obj = AricilikSayfasi.objects.create(
            baslik="Arıcılık",
            icerik="Arıcılık hakkında bilgiler buraya eklenecektir."
        )
    
    context = {
        "page_title": "Arıcılık - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Arıcılık hakkında bilgiler, arı ürünleri ve arıcılık teknikleri.",
        "aricilik": aricilik_obj,
    }
    return render(request, "core/aricilik.html", context)


def baglantilar(request):
    """Bağlantılar sayfası"""
    baglantilar = Baglanti.objects.filter(aktif=True)
    
    context = {
        "page_title": "Bağlantılar - Kütahya Arı Yetiştiricileri Birliği",
        "meta_description": "Kütahya Arı Yetiştiricileri Birliği ile ilgili önemli bağlantılar.",
        "baglantilar": baglantilar,
    }
    return render(request, "core/baglantilar.html", context)
