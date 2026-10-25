param(
    [string]$Adb = 'adb',
    [string]$ApkPath,
    [switch]$Instalar
)

$ErrorActionPreference = 'Stop'
$version = '0.11.7'
$url = 'https://github.com/opentvproject/opentv/releases/download/v0.11.7/opentv-v0.11.7.apk'
$expectedSha256 = 'CD6DEAB28A9BF865717BDE9AC57599D55C91A840493099508313693BD475E0DA'

if (-not $ApkPath) {
    $cache = Join-Path $env:TEMP 'BTV13-Manager'
    New-Item -ItemType Directory -Path $cache -Force | Out-Null
    $ApkPath = Join-Path $cache "opentv-v$version.apk"
    if (-not (Test-Path -LiteralPath $ApkPath)) {
        Invoke-WebRequest -Uri $url -OutFile $ApkPath -UseBasicParsing
    }
}

$apk = (Resolve-Path -LiteralPath $ApkPath).Path
$actualSha256 = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
if ($actualSha256 -ne $expectedSha256) {
    throw "Hash SHA-256 diferente do publicado pelo GitHub. Arquivo: $apk"
}
Write-Host "OpenTV $version verificado: $actualSha256"

if (-not $Instalar) {
    Write-Host 'Somente verificação. Para instalar, execute novamente com -Instalar.'
    return
}

$deviceLines = @(& $Adb devices)
if ($LASTEXITCODE -ne 0) { throw 'ADB não foi executado. Instale o Platform-Tools oficial ou informe -Adb.' }
$serials = @($deviceLines | Where-Object { $_ -match '^\S+\s+device\s*$' } | ForEach-Object { ($_ -split '\s+')[0] })
if ($serials.Count -ne 1) { throw "Esperado exatamente um aparelho ADB autorizado; encontrados: $($serials.Count)." }

Write-Host "Aparelho: $($serials[0])"
Write-Host 'O OpenTV será instalado sem remover o VLC nem alterar o launcher.'
$answer = Read-Host 'Confirma a instalação? Digite SIM'
if ($answer -ne 'SIM') { Write-Host 'Instalação cancelada.'; return }

& $Adb -s $serials[0] install -r $apk
if ($LASTEXITCODE -ne 0) { throw 'A instalação falhou.' }
Write-Host 'Instalado. Abra OpenTV > URL da lista M3U.'
Write-Host 'Lista: https://raw.githubusercontent.com/WingCell/BTV13-Manager/main/config/canais-da-vo.m3u'
