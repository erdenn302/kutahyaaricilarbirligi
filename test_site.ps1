# Site Durum Kontrol Scripti - PowerShell
# Yerel bilgisayardan sunucu durumunu kontrol eder

Write-Host "🔍 Site Durum Kontrolü" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host ""

# Test adresleri
$testUrls = @(
    "http://37.148.208.77",
    "http://kutahyaaricilarbirligi.com",
    "https://37.148.208.77",
    "https://kutahyaaricilarbirligi.com"
)

$results = @()

foreach ($url in $testUrls) {
    Write-Host "🌐 Test: $url" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 10 -MaximumRedirection 0 -ErrorAction Stop
        
        $statusCode = $response.StatusCode
        $statusText = if ($statusCode -eq 200) { "✅" } elseif ($statusCode -in @(301, 302)) { "⚠️" } else { "❌" }
        
        Write-Host "   $statusText HTTP $statusCode" -ForegroundColor $(if ($statusCode -eq 200) { "Green" } else { "Yellow" })
        
        if ($statusCode -eq 200) {
            $content = $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)).ToLower()
            if ($content -match "kütahya|arı|html") {
                Write-Host "   ✅ Site içeriği görünüyor" -ForegroundColor Green
            } elseif ($content -match "welcome to nginx") {
                Write-Host "   ⚠️  Nginx varsayılan sayfası görünüyor" -ForegroundColor Yellow
            } elseif ($content -match "502|bad gateway") {
                Write-Host "   ❌ 502 Bad Gateway hatası" -ForegroundColor Red
            } elseif ($content -match "500|internal server error") {
                Write-Host "   ❌ 500 Internal Server Error" -ForegroundColor Red
            } else {
                Write-Host "   ⚠️  İçerik beklenmiyor" -ForegroundColor Yellow
            }
        }
        
        $results += @{Url = $url; Status = $statusCode}
        Write-Host ""
        
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -match "SSL|certificate") {
            Write-Host "   ⚠️  SSL hatası (sertifika sorunu olabilir)" -ForegroundColor Yellow
        } elseif ($errorMessage -match "connection|timeout") {
            Write-Host "   ❌ Bağlantı hatası (site erişilemiyor)" -ForegroundColor Red
        } else {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "   ❌ HTTP $statusCode" -ForegroundColor Red
        }
        
        $results += @{Url = $url; Status = "ERROR"}
        Write-Host ""
    }
}

# Özet
Write-Host "=" * 50
Write-Host "📋 Özet:" -ForegroundColor Cyan
Write-Host ""

$successCount = ($results | Where-Object { $_.Status -eq 200 }).Count
$totalCount = $results.Count

foreach ($result in $results) {
    if ($result.Status -eq 200) {
        Write-Host "✅ $($result.Url) - Çalışıyor" -ForegroundColor Green
    } elseif ($result.Status -in @(301, 302)) {
        Write-Host "⚠️  $($result.Url) - Yönlendirme ($($result.Status))" -ForegroundColor Yellow
    } elseif ($result.Status -eq "ERROR") {
        Write-Host "❌ $($result.Url) - Hata" -ForegroundColor Red
    } else {
        Write-Host "❌ $($result.Url) - HTTP $($result.Status)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Başarılı: $successCount/$totalCount" -ForegroundColor $(if ($successCount -gt 0) { "Green" } else { "Yellow" })

if ($successCount -gt 0) {
    Write-Host ""
    Write-Host "🎉 Site çalışıyor!" -ForegroundColor Green
    Write-Host "🌐 Erişim: http://37.148.208.77" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Site çalışmıyor veya erişilemiyor" -ForegroundColor Yellow
    Write-Host "💡 Sunucuda kontrol edin: bash deploy/SITE_TAM_KONTROL.sh" -ForegroundColor Yellow
}

