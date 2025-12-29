"""
URL configuration for kutahyaaricilarbirligi project.
"""
from django.contrib import admin
from django.urls import path
from django.conf import settings
from django.conf.urls.static import static

from core import views as core_views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", core_views.home, name="home"),
    path("hakkimizda/", core_views.hakkimizda, name="hakkimizda"),
    path("haberler/", core_views.haberler, name="haberler"),
    path("haberler/<slug:slug>/", core_views.haber_detay, name="haber_detay"),
    path("duyurular/", core_views.duyurular, name="duyurular"),
    path("duyurular/<slug:slug>/", core_views.duyuru_detay, name="duyuru_detay"),
    path("projeler/", core_views.projeler, name="projeler"),
    path("projeler/<slug:slug>/", core_views.proje_detay, name="proje_detay"),
    path("aricilik/", core_views.aricilik, name="aricilik"),
    path("baglantilar/", core_views.baglantilar, name="baglantilar"),
]

# Development için media dosyalarını serve et
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
