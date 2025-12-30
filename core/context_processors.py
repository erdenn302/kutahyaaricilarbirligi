from .models import SiteAyarlari


def site_ayarlari(request):
    """Site ayarlarını tüm template'lere ekler"""
    ayarlar = SiteAyarlari.objects.first()
    if not ayarlar:
        ayarlar = SiteAyarlari.objects.create()
    return {
        'site_ayarlari': ayarlar
    }



