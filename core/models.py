from django.db import models
from django.urls import reverse
from django.utils.text import slugify
from ckeditor.fields import RichTextField


class Haber(models.Model):
    """Haberler için model"""
    baslik = models.CharField(
        max_length=200, 
        verbose_name="Başlık",
        help_text="Haber başlığını buraya yazın. Örnek: 'Yeni Proje Başladı'"
    )
    slug = models.SlugField(
        max_length=200, 
        unique=True, 
        blank=True, 
        verbose_name="URL Adresi",
        help_text="Bu alan otomatik oluşturulur. Genelde değiştirmenize gerek yok."
    )
    ozet = models.TextField(
        max_length=500, 
        verbose_name="Özet",
        help_text="Haberin kısa özeti (maksimum 500 karakter). Ana sayfada görünecek."
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Haberin detaylı içeriğini buraya yazın. Yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz."
    )
    resim = models.ImageField(
        upload_to='haberler/', 
        blank=True, 
        null=True, 
        verbose_name="Kapak Resmi",
        help_text="Haber için bir kapak resmi seçin (isteğe bağlı). Önerilen boyut: 800x600 piksel."
    )
    yayin_tarihi = models.DateTimeField(
        auto_now_add=True, 
        verbose_name="Yayın Tarihi",
        help_text="Haberin yayınlanma tarihi (otomatik oluşturulur)"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True, 
        verbose_name="Son Güncelleme",
        help_text="Son güncelleme tarihi (otomatik güncellenir)"
    )
    aktif = models.BooleanField(
        default=True, 
        verbose_name="Yayında Göster",
        help_text="Bu kutuyu işaretlerseniz haber web sitesinde görünür olur."
    )
    sira = models.IntegerField(
        default=0, 
        verbose_name="Sıralama",
        help_text="Haberlerin sıralaması için kullanılır. Düşük sayı önce görünür."
    )

    class Meta:
        verbose_name = "Haber"
        verbose_name_plural = "Haberler"
        ordering = ['-yayin_tarihi']

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.baslik)
        super().save(*args, **kwargs)

    def get_absolute_url(self):
        return reverse('haber_detay', kwargs={'slug': self.slug})


class Duyuru(models.Model):
    """Duyurular için model"""
    baslik = models.CharField(
        max_length=200, 
        verbose_name="Başlık",
        help_text="Duyuru başlığını buraya yazın. Örnek: 'Genel Kurul Toplantısı'"
    )
    slug = models.SlugField(
        max_length=200, 
        unique=True, 
        blank=True, 
        verbose_name="URL Adresi",
        help_text="Bu alan otomatik oluşturulur. Genelde değiştirmenize gerek yok."
    )
    ozet = models.TextField(
        max_length=500, 
        verbose_name="Özet",
        help_text="Duyurunun kısa özeti (maksimum 500 karakter). Ana sayfada görünecek."
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Duyurunun detaylı içeriğini buraya yazın. Yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz."
    )
    resim = models.ImageField(
        upload_to='duyurular/', 
        blank=True, 
        null=True, 
        verbose_name="Kapak Resmi",
        help_text="Duyuru için bir kapak resmi seçin (isteğe bağlı). Önerilen boyut: 800x600 piksel."
    )
    yayin_tarihi = models.DateTimeField(
        auto_now_add=True, 
        verbose_name="Yayın Tarihi",
        help_text="Duyurunun yayınlanma tarihi (otomatik oluşturulur)"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True, 
        verbose_name="Son Güncelleme",
        help_text="Son güncelleme tarihi (otomatik güncellenir)"
    )
    aktif = models.BooleanField(
        default=True, 
        verbose_name="Yayında Göster",
        help_text="Bu kutuyu işaretlerseniz duyuru web sitesinde görünür olur."
    )
    sira = models.IntegerField(
        default=0, 
        verbose_name="Sıralama",
        help_text="Duyuruların sıralaması için kullanılır. Düşük sayı önce görünür."
    )

    class Meta:
        verbose_name = "Duyuru"
        verbose_name_plural = "Duyurular"
        ordering = ['-yayin_tarihi']

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.baslik)
        super().save(*args, **kwargs)

    def get_absolute_url(self):
        return reverse('duyuru_detay', kwargs={'slug': self.slug})


class Proje(models.Model):
    """Projeler için model"""
    baslik = models.CharField(
        max_length=200, 
        verbose_name="Başlık",
        help_text="Proje başlığını buraya yazın. Örnek: 'Arı Dostu Köy Projesi'"
    )
    slug = models.SlugField(
        max_length=200, 
        unique=True, 
        blank=True, 
        verbose_name="URL Adresi",
        help_text="Bu alan otomatik oluşturulur. Genelde değiştirmenize gerek yok."
    )
    ozet = models.TextField(
        max_length=500, 
        verbose_name="Özet",
        help_text="Projenin kısa özeti (maksimum 500 karakter). Projeler sayfasında görünecek."
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Projenin detaylı açıklamasını buraya yazın. Yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz."
    )
    resim = models.ImageField(
        upload_to='projeler/', 
        blank=True, 
        null=True, 
        verbose_name="Proje Resmi",
        help_text="Proje için bir resim seçin (isteğe bağlı). Önerilen boyut: 800x600 piksel."
    )
    baslangic_tarihi = models.DateField(
        blank=True, 
        null=True, 
        verbose_name="Başlangıç Tarihi",
        help_text="Projenin başladığı tarih (isteğe bağlı)"
    )
    bitis_tarihi = models.DateField(
        blank=True, 
        null=True, 
        verbose_name="Bitiş Tarihi",
        help_text="Projenin bittiği tarih (isteğe bağlı)"
    )
    aktif = models.BooleanField(
        default=True, 
        verbose_name="Yayında Göster",
        help_text="Bu kutuyu işaretlerseniz proje web sitesinde görünür olur."
    )
    sira = models.IntegerField(
        default=0, 
        verbose_name="Sıralama",
        help_text="Projelerin sıralaması için kullanılır. Düşük sayı önce görünür."
    )

    class Meta:
        verbose_name = "Proje"
        verbose_name_plural = "Projeler"
        ordering = ['-baslangic_tarihi']

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.baslik)
        super().save(*args, **kwargs)

    def get_absolute_url(self):
        return reverse('proje_detay', kwargs={'slug': self.slug})


class Baglanti(models.Model):
    """Dış bağlantılar için model"""
    baslik = models.CharField(
        max_length=200, 
        verbose_name="Başlık",
        help_text="Bağlantının adını yazın. Örnek: 'Türkiye Arıcılar Birliği'"
    )
    url = models.URLField(
        verbose_name="Web Sitesi Adresi",
        help_text="Tam web sitesi adresini yazın. Örnek: https://www.example.com"
    )
    aciklama = models.TextField(
        blank=True, 
        null=True, 
        verbose_name="Açıklama",
        help_text="Bu bağlantı hakkında kısa bir açıklama (isteğe bağlı)"
    )
    logo = models.ImageField(
        upload_to='baglantilar/', 
        blank=True, 
        null=True, 
        verbose_name="Logo",
        help_text="Bağlantı için bir logo resmi yükleyin (isteğe bağlı)"
    )
    aktif = models.BooleanField(
        default=True, 
        verbose_name="Yayında Göster",
        help_text="Bu kutuyu işaretlerseniz bağlantı web sitesinde görünür olur."
    )
    sira = models.IntegerField(
        default=0, 
        verbose_name="Sıralama",
        help_text="Bağlantıların sıralaması için kullanılır. Düşük sayı önce görünür."
    )
    yeni_sekmede_ac = models.BooleanField(
        default=True, 
        verbose_name="Yeni Sekmede Aç",
        help_text="İşaretli olursa bağlantı yeni bir sekmede açılır."
    )

    class Meta:
        verbose_name = "Bağlantı"
        verbose_name_plural = "Bağlantılar"
        ordering = ['sira', 'baslik']

    def __str__(self):
        return self.baslik


class Hakkimizda(models.Model):
    """Hakkımızda sayfası için tek kayıt modeli"""
    baslik = models.CharField(
        max_length=200, 
        default="Hakkımızda", 
        verbose_name="Sayfa Başlığı",
        help_text="Hakkımızda sayfasının başlığı"
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Hakkımızda sayfasının içeriğini buraya yazın. Yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz."
    )
    resim = models.ImageField(
        upload_to='hakkimizda/', 
        blank=True, 
        null=True, 
        verbose_name="Sayfa Resmi",
        help_text="Hakkımızda sayfası için bir resim yükleyin (isteğe bağlı)"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True, 
        verbose_name="Son Güncelleme",
        help_text="Son güncelleme tarihi (otomatik güncellenir)"
    )

    class Meta:
        verbose_name = "Hakkımızda"
        verbose_name_plural = "Hakkımızda"

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        # Sadece bir kayıt olmasını sağla
        self.pk = 1
        super().save(*args, **kwargs)


class AricilikSayfasi(models.Model):
    """Arıcılık sayfası için tek kayıt modeli"""
    baslik = models.CharField(
        max_length=200, 
        default="Arıcılık", 
        verbose_name="Sayfa Başlığı",
        help_text="Arıcılık sayfasının başlığı"
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Arıcılık sayfasının içeriğini buraya yazın. Yazı tipi, renk, resim ekleme gibi özellikleri kullanabilirsiniz."
    )
    resim = models.ImageField(
        upload_to='aricilik/', 
        blank=True, 
        null=True, 
        verbose_name="Sayfa Resmi",
        help_text="Arıcılık sayfası için bir resim yükleyin (isteğe bağlı)"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True, 
        verbose_name="Son Güncelleme",
        help_text="Son güncelleme tarihi (otomatik güncellenir)"
    )

    class Meta:
        verbose_name = "Arıcılık Sayfası"
        verbose_name_plural = "Arıcılık Sayfası"

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        # Sadece bir kayıt olmasını sağla
        self.pk = 1
        super().save(*args, **kwargs)


class SiteAyarlari(models.Model):
    """Site genel ayarları için tek kayıt modeli"""
    site_adi = models.CharField(
        max_length=200, 
        default="Kütahya Arı Yetiştiricileri Birliği",
        verbose_name="Site Adı",
        help_text="Web sitesinin adı (üst menüde görünecek)"
    )
    logo = models.ImageField(
        upload_to='site/', 
        blank=True, 
        null=True, 
        verbose_name="Logo",
        help_text="Site logosu (önerilen boyut: 200x200 piksel veya daha büyük, şeffaf arka planlı PNG)"
    )
    favicon = models.ImageField(
        upload_to='site/', 
        blank=True, 
        null=True, 
        verbose_name="Favicon",
        help_text="Site favicon'u (tarayıcı sekmesinde görünecek, önerilen: 32x32 veya 16x16 piksel)"
    )
    telefon = models.CharField(
        max_length=20, 
        blank=True, 
        null=True,
        verbose_name="Telefon",
        help_text="İletişim telefonu (örnek: +90 274 XXX XX XX)"
    )
    email = models.EmailField(
        blank=True, 
        null=True,
        verbose_name="E-posta",
        help_text="İletişim e-posta adresi"
    )
    adres = models.TextField(
        blank=True, 
        null=True,
        verbose_name="Adres",
        help_text="Birlik adresi"
    )
    facebook_url = models.URLField(
        blank=True, 
        null=True,
        verbose_name="Facebook URL",
        help_text="Facebook sayfası linki (isteğe bağlı)"
    )
    instagram_url = models.URLField(
        blank=True, 
        null=True,
        verbose_name="Instagram URL",
        help_text="Instagram sayfası linki (isteğe bağlı)"
    )
    twitter_url = models.URLField(
        blank=True, 
        null=True,
        verbose_name="Twitter URL",
        help_text="Twitter sayfası linki (isteğe bağlı)"
    )
    youtube_url = models.URLField(
        blank=True, 
        null=True,
        verbose_name="YouTube URL",
        help_text="YouTube kanalı linki (isteğe bağlı)"
    )
    linkedin_url = models.URLField(
        blank=True, 
        null=True,
        verbose_name="LinkedIn URL",
        help_text="LinkedIn sayfası linki (isteğe bağlı)"
    )
    google_verification_code = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="Google Search Console Verification Code",
        help_text="Google Search Console'dan alınan verification code (meta tag içeriği)"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True, 
        verbose_name="Son Güncelleme",
        help_text="Son güncelleme tarihi (otomatik güncellenir)"
    )

    class Meta:
        verbose_name = "Site Ayarları"
        verbose_name_plural = "Site Ayarları"

    def __str__(self):
        return self.site_adi

    def save(self, *args, **kwargs):
        # Sadece bir kayıt olmasını sağla
        self.pk = 1
        super().save(*args, **kwargs)


class MevzuatKategori(models.Model):
    """Mevzuat kategorileri (Kanunlar, Yönetmelikler, vb.)"""
    KATEGORI_SECENEKLERI = [
        ('kanun', 'Kanunlar'),
        ('yonetmelik', 'Yönetmelikler'),
        ('genelge', 'Genelgeler'),
        ('teblig', 'Tebliğler'),
        ('talimatname', 'Talimatnameler'),
        ('anasozlesme', 'Ana Sözleşmeler'),
    ]
    
    ad = models.CharField(
        max_length=50,
        choices=KATEGORI_SECENEKLERI,
        unique=True,
        verbose_name="Kategori Adı",
        help_text="Mevzuat kategorisini seçin"
    )
    aciklama = models.TextField(
        blank=True,
        null=True,
        verbose_name="Açıklama",
        help_text="Kategori hakkında kısa açıklama (isteğe bağlı)"
    )
    sira = models.IntegerField(
        default=0,
        verbose_name="Sıra",
        help_text="Kategorilerin görüntülenme sırası (düşük sayı önce görünür)"
    )
    aktif = models.BooleanField(
        default=True,
        verbose_name="Aktif",
        help_text="Bu kategoriyi web sitesinde göster"
    )

    class Meta:
        verbose_name = "Mevzuat Kategorisi"
        verbose_name_plural = "Mevzuat Kategorileri"
        ordering = ['sira', 'ad']

    def __str__(self):
        return self.get_ad_display()


class Mevzuat(models.Model):
    """Mevzuatlar (Kanunlar, Yönetmelikler, Genelgeler, vb.)"""
    baslik = models.CharField(
        max_length=500,
        verbose_name="Başlık",
        help_text="Mevzuat başlığını buraya yazın"
    )
    kategori = models.ForeignKey(
        MevzuatKategori,
        on_delete=models.CASCADE,
        related_name='mevzuatlar',
        verbose_name="Kategori",
        help_text="Mevzuat kategorisini seçin"
    )
    dosya = models.FileField(
        upload_to='mevzuatlar/',
        blank=True,
        null=True,
        verbose_name="Dosya (PDF/DOCX)",
        help_text="Mevzuat dosyasını yükleyin (PDF veya DOCX formatında)"
    )
    dis_link = models.URLField(
        blank=True,
        null=True,
        verbose_name="Dış Link",
        help_text="Eğer dosya yoksa, dış bir link ekleyebilirsiniz (örnek: tab.org.tr linki)"
    )
    aciklama = models.TextField(
        blank=True,
        null=True,
        verbose_name="Açıklama",
        help_text="Mevzuat hakkında kısa açıklama (isteğe bağlı)"
    )
    yayin_tarihi = models.DateField(
        blank=True,
        null=True,
        verbose_name="Yayın Tarihi",
        help_text="Mevzuatın yayın tarihi (isteğe bağlı)"
    )
    sira = models.IntegerField(
        default=0,
        verbose_name="Sıra",
        help_text="Aynı kategorideki mevzuatların görüntülenme sırası"
    )
    aktif = models.BooleanField(
        default=True,
        verbose_name="Yayında Göster",
        help_text="Bu mevzuatı web sitesinde göster"
    )
    olusturma_tarihi = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Oluşturulma Tarihi"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True,
        verbose_name="Son Güncelleme"
    )

    class Meta:
        verbose_name = "Mevzuat"
        verbose_name_plural = "Mevzuatlar"
        ordering = ['kategori__sira', 'kategori__ad', 'sira', '-yayin_tarihi']

    def __str__(self):
        return f"{self.kategori.get_ad_display()} - {self.baslik}"

    def get_dosya_url(self):
        """Dosya veya dış link URL'sini döndürür"""
        if self.dosya:
            return self.dosya.url
        elif self.dis_link:
            return self.dis_link
        return None


class Kongre(models.Model):
    """Kongreler"""
    baslik = models.CharField(
        max_length=200,
        verbose_name="Başlık",
        help_text="Kongre başlığını buraya yazın. Örnek: 'X. Ulusal Arıcılık Kongresi'"
    )
    slug = models.SlugField(
        max_length=200,
        unique=True,
        blank=True,
        verbose_name="URL Adresi",
        help_text="Bu alan otomatik oluşturulur. Genelde değiştirmenize gerek yok."
    )
    ozet = models.TextField(
        max_length=500,
        verbose_name="Özet",
        help_text="Kongrenin kısa özeti (maksimum 500 karakter)"
    )
    icerik = RichTextField(
        verbose_name="İçerik",
        help_text="Kongre hakkında detaylı bilgi. Tarih, yer, konuşmacılar, program vb."
    )
    resim = models.ImageField(
        upload_to='kongreler/',
        blank=True,
        null=True,
        verbose_name="Kapak Resmi",
        help_text="Kongre için bir kapak resmi seçin (isteğe bağlı)"
    )
    tarih = models.DateField(
        verbose_name="Kongre Tarihi",
        help_text="Kongrenin yapılacağı veya yapıldığı tarih"
    )
    yer = models.CharField(
        max_length=200,
        blank=True,
        null=True,
        verbose_name="Yer",
        help_text="Kongrenin yapılacağı yer (şehir, mekan)"
    )
    link = models.URLField(
        blank=True,
        null=True,
        verbose_name="Kongre Linki",
        help_text="Kongre ile ilgili dış link (isteğe bağlı)"
    )
    aktif = models.BooleanField(
        default=True,
        verbose_name="Yayında Göster",
        help_text="Bu kongreyi web sitesinde göster"
    )
    sira = models.IntegerField(
        default=0,
        verbose_name="Sıra",
        help_text="Kongrelerin görüntülenme sırası (düşük sayı önce görünür, tarih sırasına göre)"
    )
    olusturma_tarihi = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Oluşturulma Tarihi"
    )
    guncelleme_tarihi = models.DateTimeField(
        auto_now=True,
        verbose_name="Son Güncelleme"
    )

    class Meta:
        verbose_name = "Kongre"
        verbose_name_plural = "Kongreler"
        ordering = ['-tarih', 'sira']

    def __str__(self):
        return self.baslik

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.baslik)
        super().save(*args, **kwargs)
