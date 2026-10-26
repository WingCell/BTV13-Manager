param(
    [Parameter(Mandatory)][string]$Candidate,
    [Parameter(Mandatory)][string]$Output,
    [Parameter(Mandatory)][string]$Report,
    [int]$TimeoutSeconds = 8
)

$ErrorActionPreference = 'Stop'
$lines = Get-Content -LiteralPath $Candidate -Encoding UTF8
if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '#EXTM3U') {
    throw 'Lista candidata sem cabeçalho #EXTM3U.'
}

$selected = New-Object System.Collections.Generic.List[string]
$selected.Add('#EXTM3U')
$results = New-Object System.Collections.Generic.List[object]
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$number = 0

for ($i = 1; $i -lt $lines.Count - 1; $i++) {
    if (-not $lines[$i].StartsWith('#EXTINF:')) { continue }
    $meta = $lines[$i]
    $url = $lines[++$i].Trim()
    $name = ($meta -split ',', 2)[-1]
    if (-not $seen.Add($url)) { continue }
    $number++
    $row = [ordered]@{
        canal = $name; url = $url; http = $null; tipo = $null
        destino = $null; valido = $false; erro = $null
    }
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing `
            -TimeoutSec $TimeoutSeconds -Headers @{'User-Agent'='Mozilla/5.0'}
        $body = if ($response.Content -is [byte[]]) {
            [Text.Encoding]::UTF8.GetString($response.Content)
        } else { [string]$response.Content }
        $row.http = [int]$response.StatusCode
        $row.tipo = [string]$response.Headers['Content-Type']
        $row.destino = [string]$response.BaseResponse.ResponseUri.Host
        $hlsType = $row.tipo -match '^(?i:application/(?:vnd\.apple\.mpegurl|x-mpegurl))(?:\s*;|$)'
        $pluto = $url -notlike 'https://jmp2.uk/*' -or $row.destino -like '*.pluto.tv'
        $row.valido = $row.http -eq 200 -and $hlsType -and `
            $body.TrimStart([char]0xFEFF).StartsWith('#EXTM3U') -and $pluto
        if (-not $pluto) { $row.erro = 'Redirecionamento fora da Pluto TV.' }
        elseif (-not $row.valido) { $row.erro = 'Resposta não é manifesto HLS 200 com tipo esperado.' }
    } catch {
        $row.erro = $_.Exception.Message
    }
    $results.Add([pscustomobject]$row)
    if ($row.valido) {
        $selected.Add($meta)
        $selected.Add($url)
    }
    if ($number % 10 -eq 0) {
        Write-Output "Verificados $number; válidos $(($results | Where-Object valido).Count)"
    }
}

if (($selected.Count - 1) / 2 -gt 500) { throw 'Limite de 500 canais excedido.' }
$outputDir = Split-Path -Parent $Output
$reportDir = Split-Path -Parent $Report
if ($outputDir) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
if ($reportDir) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
[IO.File]::WriteAllText((Join-Path (Get-Location) $Output),
    ($selected -join "`n") + "`n", (New-Object Text.UTF8Encoding($false)))
$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $Report -Encoding UTF8
Write-Output "Total=$number válidos=$(($results | Where-Object valido).Count) rejeitados=$(($results | Where-Object { -not $_.valido }).Count)"

