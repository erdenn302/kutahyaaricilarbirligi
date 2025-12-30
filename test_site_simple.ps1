# Site Durum Kontrol - Basit PowerShell Script

Write-Host "Site Durum Kontrolu" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

$urls = @(
    "http://37.148.208.77",
    "http://kutahyaaricilarbirligi.com"
)

foreach ($url in $urls) {
    Write-Host "Test: $url" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        $statusCode = $response.StatusCode
        
        Write-Host "  HTTP Status: $statusCode" -ForegroundColor $(if ($statusCode -eq 200) { "Green" } else { "Yellow" })
        
        if ($statusCode -eq 200) {
            $content = $response.Content.Substring(0, [Math]::Min(300, $response.Content.Length))
            if ($content -match "Kutahya|Ari|html") {
                Write-Host "  Site icerigi gorunuyor" -ForegroundColor Green
            } elseif ($content -match "nginx") {
                Write-Host "  Nginx varsayilan sayfasi" -ForegroundColor Yellow
            } elseif ($content -match "500|502") {
                Write-Host "  Hata var!" -ForegroundColor Red
            }
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "  HTTP Status: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 500) {
            Write-Host "  500 Internal Server Error" -ForegroundColor Red
        } elseif ($statusCode -eq 502) {
            Write-Host "  502 Bad Gateway" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

Write-Host "Kontrol tamamlandi!" -ForegroundColor Cyan

