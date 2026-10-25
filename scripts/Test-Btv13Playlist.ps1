param(
    [Parameter(Mandatory)][string]$Playlist,
    [string]$OutputCsv,
    [int]$TimeoutSec = 12
)

$ErrorActionPreference = 'Stop'
$lines = @(Get-Content -LiteralPath $Playlist -Encoding UTF8)
if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '#EXTM3U') {
    throw 'Arquivo M3U sem cabeçalho #EXTM3U.'
}

$results = foreach ($line in $lines) {
    if ($line -notmatch '^https?://') { continue }
    $url = $line.Trim()
    $row = [ordered]@{ Url = $url; Status = ''; ContentType = ''; HlsHeader = $false; Error = '' }
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -UserAgent 'Mozilla/5.0 (BTV13-Manager; playlist-check)' -UseBasicParsing -TimeoutSec $TimeoutSec -MaximumRedirection 5
        $row.Status = [int]$response.StatusCode
        $row.ContentType = [string]$response.Headers['Content-Type']
        $body = if ($response.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($response.Content) } else { [string]$response.Content }
        $row.HlsHeader = $body.TrimStart([char]0xFEFF, [char]0x20, [char]0x09, [char]0x0A, [char]0x0D).StartsWith('#EXTM3U')
    } catch {
        $row.Error = $_.Exception.Message
    }
    [pscustomobject]$row
}

if ($OutputCsv) {
    $results | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding UTF8
}
$results | Format-Table -AutoSize -Property Status, ContentType, HlsHeader, Error, Url
$valid = @($results | Where-Object {
    $_.Status -eq 200 -and $_.HlsHeader -and
    $_.ContentType -match '^application/(vnd\.apple\.mpegurl|x-mpegurl)(;|$)'
})
Write-Host "Manifestos HLS validos: $($valid.Count)/$(@($results).Count)"
if ($valid.Count -ne @($results).Count) { exit 1 }

