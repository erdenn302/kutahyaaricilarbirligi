from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from .models import Haber, Duyuru, Proje, Kongre


class StaticViewSitemap(Sitemap):
    """Statik sayfalar için sitemap"""
    priority = 1.0
    changefreq = 'monthly'

    def items(self):
        return [
            'home',
            'hakkimizda',
            'haberler',
            'duyurular',
            'projeler',
            'aricilik',
            'mevzuatlar',
            'kongreler',
            'baglantilar',
        ]

    def location(self, item):
        return reverse(item)


class HaberSitemap(Sitemap):
    """Haberler için sitemap"""
    changefreq = 'weekly'
    priority = 0.8

    def items(self):
        return Haber.objects.filter(aktif=True).order_by('-yayin_tarihi')

    def lastmod(self, obj):
        return obj.guncelleme_tarihi


class DuyuruSitemap(Sitemap):
    """Duyurular için sitemap"""
    changefreq = 'weekly'
    priority = 0.8

    def items(self):
        return Duyuru.objects.filter(aktif=True).order_by('-yayin_tarihi')

    def lastmod(self, obj):
        return obj.guncelleme_tarihi


class ProjeSitemap(Sitemap):
    """Projeler için sitemap"""
    changefreq = 'monthly'
    priority = 0.7

    def items(self):
        return Proje.objects.filter(aktif=True).order_by('-olusturma_tarihi')

    def lastmod(self, obj):
        return obj.guncelleme_tarihi

