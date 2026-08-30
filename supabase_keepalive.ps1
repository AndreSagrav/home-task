# Supabase Keep-Alive Anti-Pausa Script
# Mantiene activo el proyecto de Supabase realizando peticiones periódicas a la API REST.

$SupaUrl = "https://chrslplxjzfjnfvvazgu.supabase.co/rest/v1/houses?select=id&limit=1"
$SupaKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNocnNscGx4anpmam5mdnZhemd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2Nzc3OTcsImV4cCI6MjA4ODI1Mzc5N30.09_90M7rtJ12KeQcbipt_ohR2_uJoT1UsylddWD6rno"

$Headers = @{
    "apikey" = $SupaKey
    "Authorization" = "Bearer $SupaKey"
}

try {
    $res = Invoke-RestMethod -Uri $SupaUrl -Headers $Headers -Method Get -TimeoutSec 15
    $log = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Supabase Ping OK - Proyecto activo."
    Write-Output $log
    Add-Content -Path "$PSScriptRoot\supabase_keepalive.log" -Value $log -ErrorAction SilentlyContinue
} catch {
    $err = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error en Supabase Ping: $($_.Exception.Message)"
    Write-Output $err
    Add-Content -Path "$PSScriptRoot\supabase_keepalive.log" -Value $err -ErrorAction SilentlyContinue
}
