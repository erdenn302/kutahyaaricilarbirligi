#!/usr/bin/env python
"""
Site Durum Kontrol Scripti
Yerel bilgisayardan sunucu durumunu kontrol eder
"""

import requests
import sys

def check_site():
    """Site durumunu kontrol et"""
    print("🔍 Site Durum Kontrolü")
    print("=" * 50)
    print()
    
    # Test adresleri
    test_urls = [
        "http://37.148.208.77",
        "http://kutahyaaricilarbirligi.com",
        "https://37.148.208.77",
        "https://kutahyaaricilarbirligi.com",
    ]
    
    results = []
    
    for url in test_urls:
        try:
            print(f"🌐 Test: {url}")
            response = requests.get(url, timeout=10, allow_redirects=False)
            
            status_code = response.status_code
            status_text = "✅" if status_code == 200 else "⚠️" if status_code in [301, 302] else "❌"
            
            print(f"   {status_text} HTTP {status_code}")
            
            if status_code == 200:
                # İçerik kontrolü
                content = response.text[:200].lower()
                if "kütahya" in content or "arı" in content or "html" in content:
                    print("   ✅ Site içeriği görünüyor")
                elif "welcome to nginx" in content:
                    print("   ⚠️  Nginx varsayılan sayfası görünüyor")
                elif "502" in content or "bad gateway" in content:
                    print("   ❌ 502 Bad Gateway hatası")
                elif "500" in content or "internal server error" in content:
                    print("   ❌ 500 Internal Server Error")
                else:
                    print("   ⚠️  İçerik beklenmiyor")
            
            results.append((url, status_code))
            print()
            
        except requests.exceptions.SSLError:
            print(f"   ⚠️  SSL hatası (sertifika sorunu olabilir)")
            print()
            results.append((url, "SSL_ERROR"))
        except requests.exceptions.ConnectionError:
            print(f"   ❌ Bağlantı hatası (site erişilemiyor)")
            print()
            results.append((url, "CONNECTION_ERROR"))
        except requests.exceptions.Timeout:
            print(f"   ❌ Zaman aşımı")
            print()
            results.append((url, "TIMEOUT"))
        except Exception as e:
            print(f"   ❌ Hata: {str(e)}")
            print()
            results.append((url, "ERROR"))
    
    # Özet
    print("=" * 50)
    print("📋 Özet:")
    print()
    
    success_count = sum(1 for _, status in results if status == 200)
    total_count = len(results)
    
    for url, status in results:
        if status == 200:
            print(f"✅ {url} - Çalışıyor")
        elif status in [301, 302]:
            print(f"⚠️  {url} - Yönlendirme ({status})")
        elif status == "SSL_ERROR":
            print(f"⚠️  {url} - SSL hatası")
        elif status == "CONNECTION_ERROR":
            print(f"❌ {url} - Bağlantı hatası")
        else:
            print(f"❌ {url} - HTTP {status}")
    
    print()
    print(f"✅ Başarılı: {success_count}/{total_count}")
    
    if success_count > 0:
        print()
        print("🎉 Site çalışıyor!")
        print("🌐 Erişim: http://37.148.208.77")
    else:
        print()
        print("⚠️  Site çalışmıyor veya erişilemiyor")
        print("💡 Sunucuda kontrol edin: bash deploy/SITE_TAM_KONTROL.sh")

if __name__ == "__main__":
    try:
        check_site()
    except KeyboardInterrupt:
        print("\n\n❌ İşlem iptal edildi")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Hata: {str(e)}")
        sys.exit(1)

