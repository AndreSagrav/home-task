# Supabase Keep-Alive Anti-Pausa Script
# Mantiene activo el proyecto de Supabase realizando peticiones periódicas a la API REST.

$SupaUrl = "https://chrslplxjzfjnfvvazgu.supabase.co/rest/v1/houses?select=id&limit=1"
$SupaKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNocnNscGx4anpmam5mdnZhemd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2Nzc3OTcsImV4cCI6MjA4ODI1Mzc5N30.09_90M7rtJ12KeQcbipt_ohR2_uJoT1UsylddWD6rno"

$Headers = @{
    "apikey" = $SupaKey
    "Authorization" = "Bearer $SupaKey"
}

$maxRetries = 5
$retryDelaySec = 15
$success = $false

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
        $res = Invoke-RestMethod -Uri $SupaUrl -Headers $Headers -Method Get -TimeoutSec 15
        $log = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Supabase Ping OK - Proyecto activo (Intento $attempt)."
        Write-Output $log
        Add-Content -Path "$PSScriptRoot\supabase_keepalive.log" -Value $log -ErrorAction SilentlyContinue
        $success = $true
        break
    } catch {
        $msg = $_.Exception.Message
        $err = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Advertencia en intento $attempt de ${maxRetries} - $msg"
        Write-Output $err
        Add-Content -Path "$PSScriptRoot\supabase_keepalive.log" -Value $err -ErrorAction SilentlyContinue
        if ($attempt -lt $maxRetries) {
            Start-Sleep -Seconds $retryDelaySec
        }
    }
}

if (-not $success) {
    $fatal = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error critico: Supabase Ping fallo tras ${maxRetries} intentos."
    Write-Output $fatal
    Add-Content -Path "$PSScriptRoot\supabase_keepalive.log" -Value $fatal -ErrorAction SilentlyContinue
}
