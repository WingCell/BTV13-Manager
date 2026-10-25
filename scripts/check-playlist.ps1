param(
    [string]$Playlist = (Join-Path $PSScriptRoot '..\config\canais-da-vo.m3u'),
    [string]$Report = (Join-Path $PSScriptRoot '..\reports\playlist-check.json')
)

$lines = Get-Content -LiteralPath $Playlist -Encoding UTF8
if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '#EXTM3U') {
    throw 'O arquivo não começa com #EXTM3U.'
}

$results = @()
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].StartsWith('#EXTINF:')) { continue }
    $name = ($lines[$i] -split ',', 2)[-1].Trim()
    if ($i + 1 -ge $lines.Count) {
        throw "URL ausente após o canal $name."
    }
    $url = $lines[++$i].Trim()
    # Exceção documentada: a TV Paraná oferece este sinal público apenas por HTTP.
    if ($url -notmatch '^https://' -and $url -ne 'http://200.189.113.201/hls/tve.m3u8') {
        throw "URL não aprovada após o canal $name."
    }
    $row = [ordered]@{ canal = $name; http = $null; hls = $false; destino = $null; erro = $null }
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        $body = if ($response.Content -is [byte[]]) {
            [Text.Encoding]::UTF8.GetString($response.Content)
        } else { [string]$response.Content }
        $row.http = [int]$response.StatusCode
        $row.hls = $body.TrimStart([char]0xFEFF).StartsWith('#EXTM3U')
        $row.destino = $response.BaseResponse.ResponseUri.Host
        if ($url -match '^https://jmp2\.uk/' -and $row.destino -notlike '*.pluto.tv') {
            $row.hls = $false
            $row.erro = 'Redirecionamento fora da Pluto TV.'
        }
    } catch {
        $row.erro = $_.Exception.Message
    }
    $results += [pscustomobject]$row
}

$reportDir = Split-Path -Parent $Report
if ($reportDir) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$results | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $Report -Encoding UTF8
$results | Format-Table -AutoSize
if ($results | Where-Object { -not $_.hls -or $_.erro }) { exit 1 }
