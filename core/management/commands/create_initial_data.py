from django.core.management.base import BaseCommand
from core.models import Baglanti


class Command(BaseCommand):
    help = 'İlk bağlantıları oluşturur'

    def handle(self, *args, **options):
        baglantilar = [
            {
                'baslik': 'Türkiye Arı Yetiştiricileri Merkez Birliği',
                'url': 'https://tab.org.tr/',
                'aciklama': 'Türkiye Arı Yetiştiricileri Merkez Birliği resmi web sitesi',
                'sira': 1,
            },
            {
                'baslik': 'Tarım ve Orman Bakanlığı',
                'url': 'https://www.tarimorman.gov.tr/',
                'aciklama': 'Tarım ve Orman Bakanlığı resmi web sitesi',
                'sira': 2,
            },
            {
                'baslik': 'Kütahya Valiliği',
                'url': 'https://www.kutahya.gov.tr/',
                'aciklama': 'Kütahya Valiliği resmi web sitesi',
                'sira': 3,
            },
            {
                'baslik': 'Naturel Arıcılık',
                'url': 'https://www.naturelaricilik.com/',
                'aciklama': 'Doğal arıcılık ve arı ürünleri',
                'sira': 4,
            },
            {
                'baslik': 'Kütahya Belediyesi',
                'url': 'https://www.kutahya.bel.tr/',
                'aciklama': 'Kütahya Büyükşehir Belediyesi resmi web sitesi',
                'sira': 5,
            },
            {
                'baslik': 'Apimondia World',
                'url': 'https://www.apimondia.org/',
                'aciklama': 'Dünya Arıcılık Kongresi ve organizasyonu',
                'sira': 6,
            },
            {
                'baslik': 'Apiterapi Derneği',
                'url': 'https://www.apiterapi.org/',
                'aciklama': 'Arı ürünleri ile tedavi ve sağlık',
                'sira': 7,
            },
            {
                'baslik': 'Arıcılık Araştırma Enstitüsü',
                'url': 'https://arastirma.tarimorman.gov.tr/aricilik/',
                'aciklama': 'Arıcılık Araştırma Enstitüsü resmi web sitesi',
                'sira': 8,
            },
        ]

        for baglanti_data in baglantilar:
            baglanti, created = Baglanti.objects.get_or_create(
                baslik=baglanti_data['baslik'],
                defaults={
                    'url': baglanti_data['url'],
                    'aciklama': baglanti_data.get('aciklama', ''),
                    'sira': baglanti_data['sira'],
                    'aktif': True,
                    'yeni_sekmede_ac': True,
                }
            )
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Bağlantı oluşturuldu: {baglanti.baslik}')
                )
            else:
                self.stdout.write(
                    self.style.WARNING(f'Bağlantı zaten mevcut: {baglanti.baslik}')
                )

        self.stdout.write(
            self.style.SUCCESS('Bağlantılar başarıyla oluşturuldu!')
        )


