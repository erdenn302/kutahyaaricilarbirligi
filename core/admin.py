from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
from .models import Haber, Duyuru, Proje, Baglanti, Hakkimizda, AricilikSayfasi, SiteAyarlari, MevzuatKategori, Mevzuat, Kongre

# Admin site özelleştirmeleri
admin.site.site_header = "Kütahya Arı Yetiştiricileri Birliği - Yönetim Paneli"
admin.site.site_title = "Kütahya Arı Yetiştiricileri Birliği"
admin.site.index_title = "Hoş Geldiniz! İçerikleri buradan yönetebilirsiniz."


@admin.register(Haber)
class HaberAdmin(admin.ModelAdmin):
    list_display = ['baslik_kisa', 'resim_onizleme', 'yayin_tarihi', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['aktif', 'yayin_tarihi']
    search_fields = ['baslik', 'icerik']
    prepopulated_fields = {'slug': ('baslik',)}
    date_hierarchy = 'yayin_tarihi'
    list_editable = ['aktif', 'sira']
    readonly_fields = ['yayin_tarihi', 'guncelleme_tarihi', 'resim_onizleme']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'slug', 'ozet', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Haberin başlığını, özetini ve detaylı içeriğini buradan düzenleyebilirsiniz. İçerik alanında yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Haber için bir kapak resmi yükleyebilirsiniz. Önerilen boyut: 800x600 piksel. Resim yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz haber web sitesinde görünür olur. Sıralama numarası düşük olan haberler önce görünür.</div>'
        }),
        ('📅 Tarih Bilgileri', {
            'fields': ('yayin_tarihi', 'guncelleme_tarihi'),
            'classes': ('collapse',),
            'description': 'Bu bilgiler otomatik olarak oluşturulur ve güncellenir.'
        }),
    )
    
    def baslik_kisa(self, obj):
        return obj.baslik[:50] + '...' if len(obj.baslik) > 50 else obj.baslik
    baslik_kisa.short_description = 'Başlık'
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Yayında</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Yayında Değil</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Duyuru)
class DuyuruAdmin(admin.ModelAdmin):
    list_display = ['baslik_kisa', 'resim_onizleme', 'yayin_tarihi', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['aktif', 'yayin_tarihi']
    search_fields = ['baslik', 'icerik']
    prepopulated_fields = {'slug': ('baslik',)}
    date_hierarchy = 'yayin_tarihi'
    list_editable = ['aktif', 'sira']
    readonly_fields = ['yayin_tarihi', 'guncelleme_tarihi', 'resim_onizleme']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'slug', 'ozet', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Duyurunun başlığını, özetini ve detaylı içeriğini buradan düzenleyebilirsiniz. İçerik alanında yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Duyuru için bir kapak resmi yükleyebilirsiniz. Önerilen boyut: 800x600 piksel. Resim yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz duyuru web sitesinde görünür olur. Sıralama numarası düşük olan duyurular önce görünür.</div>'
        }),
        ('📅 Tarih Bilgileri', {
            'fields': ('yayin_tarihi', 'guncelleme_tarihi'),
            'classes': ('collapse',),
            'description': 'Bu bilgiler otomatik olarak oluşturulur ve güncellenir.'
        }),
    )
    
    def baslik_kisa(self, obj):
        return obj.baslik[:50] + '...' if len(obj.baslik) > 50 else obj.baslik
    baslik_kisa.short_description = 'Başlık'
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Yayında</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Yayında Değil</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Proje)
class ProjeAdmin(admin.ModelAdmin):
    list_display = ['baslik_kisa', 'resim_onizleme', 'baslangic_tarihi', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['aktif', 'baslangic_tarihi']
    search_fields = ['baslik', 'icerik']
    prepopulated_fields = {'slug': ('baslik',)}
    list_editable = ['aktif', 'sira']
    readonly_fields = ['resim_onizleme']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'slug', 'ozet', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Projenin başlığını, özetini ve detaylı açıklamasını buradan düzenleyebilirsiniz. İçerik alanında yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Proje için bir resim yükleyebilirsiniz. Önerilen boyut: 800x600 piksel. Resim yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('📅 Tarih Bilgileri', {
            'fields': ('baslangic_tarihi', 'bitis_tarihi'),
            'description': '<div style="background-color: #f8d7da; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📅 Tarih Seçimi:</strong> Projenin başlangıç ve bitiş tarihlerini belirleyebilirsiniz. Bu alanlar isteğe bağlıdır.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz proje web sitesinde görünür olur. Sıralama numarası düşük olan projeler önce görünür.</div>'
        }),
    )
    
    def baslik_kisa(self, obj):
        return obj.baslik[:50] + '...' if len(obj.baslik) > 50 else obj.baslik
    baslik_kisa.short_description = 'Başlık'
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Yayında</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Yayında Değil</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Baglanti)
class BaglantiAdmin(admin.ModelAdmin):
    list_display = ['baslik', 'url_kisa', 'logo_onizleme', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['aktif']
    search_fields = ['baslik', 'url', 'aciklama']
    list_editable = ['aktif', 'sira']
    readonly_fields = ['logo_onizleme']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'url', 'aciklama'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Bağlantının adını, web sitesi adresini (https:// ile başlamalı) ve açıklamasını buradan düzenleyebilirsiniz.</div>'
        }),
        ('🖼️ Logo', {
            'fields': ('logo', 'logo_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Logo Yükleme:</strong> Bağlantı için bir logo resmi yükleyebilirsiniz (isteğe bağlı). Logo yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira', 'yeni_sekmede_ac'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz bağlantı web sitesinde görünür olur. "Yeni Sekmede Aç" kutusunu işaretlerseniz bağlantı yeni bir sekmede açılır.</div>'
        }),
    )
    
    def url_kisa(self, obj):
        return obj.url[:50] + '...' if len(obj.url) > 50 else obj.url
    url_kisa.short_description = 'Web Adresi'
    
    def logo_onizleme(self, obj):
        if obj.logo:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.logo.url)
        return format_html('<span style="color: #999; font-style: italic;">Logo yüklenmemiş</span>')
    logo_onizleme.short_description = 'Logo Önizleme'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Yayında</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Yayında Değil</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Hakkimizda)
class HakkimizdaAdmin(admin.ModelAdmin):
    readonly_fields = ['guncelleme_tarihi', 'resim_onizleme']
    
    fieldsets = (
        ('📝 İçerik', {
            'fields': ('baslik', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Hakkımızda sayfasının başlığını ve içeriğini buradan düzenleyebilirsiniz. İçerik alanında yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz. Bu sayfa sadece bir kez oluşturulur ve güncellenir.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Hakkımızda sayfası için bir resim yükleyebilirsiniz (isteğe bağlı). Resim yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('📅 Güncelleme Bilgisi', {
            'fields': ('guncelleme_tarihi',),
            'classes': ('collapse',),
            'description': 'Bu bilgi otomatik olarak güncellenir.'
        }),
    )
    
    def has_add_permission(self, request):
        # Sadece bir kayıt olmasını sağla
        return not Hakkimizda.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'


@admin.register(AricilikSayfasi)
class AricilikSayfasiAdmin(admin.ModelAdmin):
    readonly_fields = ['guncelleme_tarihi', 'resim_onizleme']
    
    fieldsets = (
        ('📝 İçerik', {
            'fields': ('baslik', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 İpucu:</strong> Arıcılık sayfasının başlığını ve içeriğini buradan düzenleyebilirsiniz. İçerik alanında yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz. Bu sayfa sadece bir kez oluşturulur ve güncellenir.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Arıcılık sayfası için bir resim yükleyebilirsiniz (isteğe bağlı). Resim yükledikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz.</div>'
        }),
        ('📅 Güncelleme Bilgisi', {
            'fields': ('guncelleme_tarihi',),
            'classes': ('collapse',),
            'description': 'Bu bilgi otomatik olarak güncellenir.'
        }),
    )
    
    def has_add_permission(self, request):
        # Sadece bir kayıt olmasını sağla
        return not AricilikSayfasi.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'


@admin.register(SiteAyarlari)
class SiteAyarlariAdmin(admin.ModelAdmin):
    readonly_fields = ['guncelleme_tarihi', 'logo_onizleme', 'favicon_onizleme']
    
    fieldsets = (
        ('🏠 Temel Bilgiler', {
            'fields': ('site_adi', 'logo', 'logo_onizleme', 'favicon', 'favicon_onizleme'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 Logo Yükleme:</strong> Site logosunu buradan yükleyebilirsiniz. Logo yüklendikten sonra kaydedip tekrar açtığınızda önizlemesini görebilirsiniz. Önerilen boyut: 200x200 piksel veya daha büyük, şeffaf arka planlı PNG formatı.</div>'
        }),
        ('📞 İletişim Bilgileri', {
            'fields': ('telefon', 'email', 'adres'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📞 İletişim:</strong> Birlik iletişim bilgilerini buradan güncelleyebilirsiniz. Bu bilgiler footer bölümünde görünecektir.</div>'
        }),
        ('🌐 Sosyal Medya', {
            'fields': ('facebook_url', 'instagram_url', 'twitter_url', 'youtube_url', 'linkedin_url'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>🌐 Sosyal Medya:</strong> Sosyal medya hesaplarınızın linklerini buradan ekleyebilirsiniz. Bu linkler footer bölümünde görünecektir.</div>'
        }),
        ('🔍 SEO Ayarları', {
            'fields': ('google_verification_code',),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>🔍 Google Search Console:</strong> Google Search Console\'dan aldığınız verification code\'u buraya yapıştırın. Detaylı bilgi için GOOGLE_SEO_REHBERI.md dosyasına bakın.</div>'
        }),
        ('📅 Güncelleme Bilgisi', {
            'fields': ('guncelleme_tarihi',),
            'classes': ('collapse',),
            'description': 'Bu bilgi otomatik olarak güncellenir.'
        }),
    )
    
    def has_add_permission(self, request):
        # Sadece bir kayıt olmasını sağla
        return not SiteAyarlari.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False
    
    def logo_onizleme(self, obj):
        if obj.logo:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 200px; border: 2px solid #ddd; border-radius: 5px; padding: 5px; background: #f8f9fa;" />', obj.logo.url)
        return format_html('<span style="color: #999; font-style: italic;">Logo yüklenmemiş</span>')
    logo_onizleme.short_description = 'Logo Önizleme'
    
    def favicon_onizleme(self, obj):
        if obj.favicon:
            return format_html('<img src="{}" style="max-width: 64px; max-height: 64px; border: 2px solid #ddd; border-radius: 5px; padding: 5px; background: #f8f9fa;" />', obj.favicon.url)
        return format_html('<span style="color: #999; font-style: italic;">Favicon yüklenmemiş</span>')
    favicon_onizleme.short_description = 'Favicon Önizleme'


@admin.register(MevzuatKategori)
class MevzuatKategoriAdmin(admin.ModelAdmin):
    list_display = ['ad', 'sira', 'aktif', 'aktif_durumu']
    list_filter = ['aktif']
    list_editable = ['sira', 'aktif']
    readonly_fields = []
    
    fieldsets = (
        ('📋 Temel Bilgiler', {
            'fields': ('ad', 'aciklama', 'sira', 'aktif'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 Kategori:</strong> Mevzuat kategorisini seçin. Kategoriler mevzuatlar sayfasında gruplandırılmış olarak görünecektir.</div>'
        }),
    )
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Aktif</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Pasif</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Mevzuat)
class MevzuatAdmin(admin.ModelAdmin):
    list_display = ['baslik_kisa', 'kategori', 'yayin_tarihi', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['kategori', 'aktif', 'yayin_tarihi']
    search_fields = ['baslik', 'aciklama']
    date_hierarchy = 'yayin_tarihi'
    list_editable = ['aktif', 'sira']
    readonly_fields = ['olusturma_tarihi', 'guncelleme_tarihi']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'kategori', 'aciklama'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 Mevzuat:</strong> Mevzuat başlığını ve kategorisini buradan düzenleyebilirsiniz.</div>'
        }),
        ('📄 Dosya / Link', {
            'fields': ('dosya', 'dis_link'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📄 Dosya Yükleme:</strong> PDF veya DOCX dosyası yükleyebilir veya dış bir link (örnek: tab.org.tr) ekleyebilirsiniz. En az birini doldurmalısınız.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira', 'yayin_tarihi'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz mevzuat web sitesinde görünür olur.</div>'
        }),
        ('📅 Tarih Bilgileri', {
            'fields': ('olusturma_tarihi', 'guncelleme_tarihi'),
            'classes': ('collapse',),
            'description': 'Bu bilgiler otomatik olarak oluşturulur ve güncellenir.'
        }),
    )
    
    def baslik_kisa(self, obj):
        return obj.baslik[:60] + '...' if len(obj.baslik) > 60 else obj.baslik
    baslik_kisa.short_description = 'Başlık'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Aktif</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Pasif</span>')
    aktif_durumu.short_description = 'Durum'


@admin.register(Kongre)
class KongreAdmin(admin.ModelAdmin):
    list_display = ['baslik_kisa', 'tarih', 'yer', 'resim_onizleme', 'aktif', 'aktif_durumu', 'sira']
    list_filter = ['aktif', 'tarih']
    search_fields = ['baslik', 'ozet', 'icerik']
    date_hierarchy = 'tarih'
    list_editable = ['aktif', 'sira']
    prepopulated_fields = {'slug': ('baslik',)}
    readonly_fields = ['olusturma_tarihi', 'guncelleme_tarihi', 'resim_onizleme']
    
    fieldsets = (
        ('📝 Temel Bilgiler', {
            'fields': ('baslik', 'slug', 'ozet', 'icerik'),
            'description': '<div style="background-color: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>💡 Kongre:</strong> Kongre başlığını, özetini ve detaylı içeriğini buradan düzenleyebilirsiniz.</div>'
        }),
        ('🖼️ Görsel', {
            'fields': ('resim', 'resim_onizleme'),
            'description': '<div style="background-color: #fff3cd; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📷 Resim Yükleme:</strong> Kongre için bir kapak resmi yükleyebilirsiniz. Önerilen boyut: 800x600 piksel.</div>'
        }),
        ('📅 Tarih ve Yer', {
            'fields': ('tarih', 'yer', 'link'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>📅 Kongre Bilgileri:</strong> Kongre tarihi, yeri ve ilgili link bilgilerini buradan ekleyebilirsiniz.</div>'
        }),
        ('⚙️ Ayarlar', {
            'fields': ('aktif', 'sira'),
            'description': '<div style="background-color: #d1ecf1; padding: 10px; border-radius: 5px; margin-bottom: 10px;"><strong>⚙️ Yayın Ayarları:</strong> "Yayında Göster" kutusunu işaretlerseniz kongre web sitesinde görünür olur.</div>'
        }),
        ('📅 Tarih Bilgileri', {
            'fields': ('olusturma_tarihi', 'guncelleme_tarihi'),
            'classes': ('collapse',),
            'description': 'Bu bilgiler otomatik olarak oluşturulur ve güncellenir.'
        }),
    )
    
    def baslik_kisa(self, obj):
        return obj.baslik[:50] + '...' if len(obj.baslik) > 50 else obj.baslik
    baslik_kisa.short_description = 'Başlık'
    
    def resim_onizleme(self, obj):
        if obj.resim:
            return format_html('<img src="{}" style="max-width: 200px; max-height: 150px; border: 2px solid #ddd; border-radius: 5px; padding: 5px;" />', obj.resim.url)
        return format_html('<span style="color: #999; font-style: italic;">Resim yüklenmemiş</span>')
    resim_onizleme.short_description = 'Resim Önizleme'
    
    def aktif_durumu(self, obj):
        if obj.aktif:
            return format_html('<span style="color: green; font-weight: bold;">✓ Aktif</span>')
        return format_html('<span style="color: red; font-weight: bold;">✗ Pasif</span>')
    aktif_durumu.short_description = 'Durum'
