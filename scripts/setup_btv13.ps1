param([Parameter(Mandatory)][string]$Serial)

$ErrorActionPreference = 'Stop'
$rootDir = Split-Path -Parent $PSScriptRoot
$playlist = Join-Path $rootDir 'config\btv13_custom.m3u'
$remote = '/sdcard/Download/BTV13_ESSENCIAIS.m3u'
$localAdb = Join-Path $rootDir 'tools\platform-tools\adb.exe'
$adbExe = if (Test-Path -LiteralPath $localAdb) { $localAdb } else { (Get-Command adb -ErrorAction Stop).Source }

function Invoke-Adb {
    param([Parameter(Mandatory)][string[]]$Arguments)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue' # adb escreve progresso em stderr mesmo quando termina com sucesso.
    try {
        $result = (& $adbExe @Arguments 2>&1 | Out-String).Trim()
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    if ($code -ne 0) { throw "ADB falhou: $result" }
    return $result
}
$lines = Get-Content -LiteralPath $playlist -Encoding UTF8
if ($lines[0] -ne '#EXTM3U' -or @($lines | Where-Object { $_ -like '#EXTINF:*' }).Count -ne 10) {
    throw 'A lista curta deve ter cabeçalho M3U e exatamente 10 canais.'
}
if ($lines | Where-Object { $_ -match '^(http://|rtmp://)' }) {
    throw 'A lista contém uma URL não HTTPS.'
}

$state = Invoke-Adb -Arguments @('-s', $Serial, 'get-state')
if ($state -ne 'device') { throw "BTV não autorizado/conectado: $state" }

$null = & $adbExe -s $Serial shell test -f $remote 2>$null
if ($LASTEXITCODE -eq 0) {
    $backupDir = Join-Path $rootDir 'backups'
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    $backup = Join-Path $backupDir ('BTV13_ESSENCIAIS_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.m3u')
    Invoke-Adb -Arguments @('-s', $Serial, 'pull', $remote, $backup) | Out-Null
    Write-Host "Cópia anterior salva em: $backup"
}

Invoke-Adb -Arguments @('-s', $Serial, 'push', $playlist, $remote) | Out-Null
$remoteSizeText = Invoke-Adb -Arguments @('-s', $Serial, 'shell', 'wc', '-c', $remote)
$remoteSize = [int64](($remoteSizeText -split '\s+')[0])
$localSize = (Get-Item -LiteralPath $playlist).Length
if ($remoteSize -ne $localSize) { throw "Tamanho diferente: local=$localSize, BTV=$remoteSize." }

$logDir = Join-Path $rootDir 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$entry = [ordered]@{ at = (Get-Date).ToString('o'); action = 'push-playlist-essenciais'; serial = $Serial; remote = $remote; bytes = $remoteSize }
Add-Content -LiteralPath (Join-Path $logDir 'setup-actions.jsonl') -Value ($entry | ConvertTo-Json -Compress) -Encoding UTF8
Write-Host "Lista curta copiada e conferida: $remote ($remoteSize bytes)."
Write-Host 'O fornecedor atual de 29 canais continua intacto.'
Write-Host 'URL para adicionar como outra fonte no OpenTV:'
Write-Host 'https://raw.githubusercontent.com/WingCell/BTV13-Manager/main/config/btv13_custom.m3u'
