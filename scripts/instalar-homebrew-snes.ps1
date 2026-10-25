param(
    [Parameter(Mandatory)][string]$Serial,
    [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$localAdb = Join-Path $root 'tools\platform-tools\adb.exe'
$adb = if (Test-Path -LiteralPath $localAdb) { $localAdb } else { (Get-Command adb -ErrorAction Stop).Source }
$sourceBase = 'https://raw.githubusercontent.com/retrobrews/snes-games/master/'
$remoteDir = '/sdcard/Games/SNES'

# ROMs homebrew oferecidas pelo projeto retrobrews para download individual.
# Não redistribua os arquivos: o README do projeto limita a autorização de distribuição ao próprio projeto.
$games = @(
    @{ Name='BLT.sfc'; Source='blt.sfc'; Bytes=262144; Sha='1f4004deb5981fa6115c1d3676add48d5437a3edb52a9203fbe14085fcb0b7ac' },
    @{ Name='Bucket.smc'; Source='bucket.smc'; Bytes=262144; Sha='e65d491ca829210d4fa93938b235d1014359a56932f9e55b4543abf23c5ac343' },
    @{ Name='Rockfall.smc'; Source='rockfall.smc'; Bytes=393728; Sha='00bb25ff9d54b2e6944ea90080d6fc6ca5a4651e496d79823fe808890a27b912' },
    @{ Name='megafamilybros.smc'; Source='megafamilybros.smc'; Bytes=1048576; Sha='693b5c373e935339b29a071ba820fedbc0257996466fbb76aea0d095f628ecfd' },
    @{ Name='hilda.sfc'; Source='hilda.sfc'; Bytes=262144; Sha='bb783bd76eb7336d284506639e9167a4c190516ef93193bb2c83f95a806d36c8' },
    @{ Name='furryrpg.sfc'; Source='furryrpg.sfc'; Bytes=6291456; Sha='20d73987555f7baf7d342b2dd1edd61576faa590c1cc11bddc6a95ab96edb12a' },
    @{ Name='questformoney.sfc'; Source='questformoney.sfc'; Bytes=262144; Sha='dde3159ee982715d7932a96344994b75798676f7df5411f3517eb0c3b6061e90' },
    @{ Name='jetpilotrising.sfc'; Source='jetpilotrising.sfc'; Bytes=524288; Sha='9b572edc8e9140fb5d86bf2e300fb0345a09eb5443c3547500d40b21f78034db' },
    @{ Name='horizontal-shooter.sfc'; Source='horizontal-shooter.sfc'; Bytes=109824; Sha='3f6f83b5cb0be44dcd1a905cd57a2a8a1a77d320585d1894d0a02c84b33d6067' },
    @{ Name='superbossgaiden.sfc'; Source='superbossgaiden.sfc'; Bytes=524288; Sha='4cdb38a4309690fb60369fc865aade000e7e791b8f979612ae7fedc0c9127486' }
)

function Invoke-Adb {
    param([string[]]$Arguments)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue' # adb pode escrever progresso em stderr e terminar com êxito.
    try {
        $result = (& $adb @Arguments 2>&1 | Out-String).Trim()
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previous
    }
    if ($code -ne 0) { throw "ADB falhou: $result" }
    return $result
}

if ((Invoke-Adb -Arguments @('-s', $Serial, 'get-state')) -ne 'device') {
    throw "BTV não autorizado ou desconectado: $Serial"
}

$cache = Join-Path ([IO.Path]::GetTempPath()) 'btv13-homebrew-cache'
if (-not $VerifyOnly) {
    New-Item -ItemType Directory -Path $cache -Force | Out-Null
    Invoke-Adb -Arguments @('-s', $Serial, 'shell', 'mkdir', '-p', $remoteDir) | Out-Null
}

$verified = 0
foreach ($game in $games) {
    $remote = "$remoteDir/$($game.Name)"
    $remoteHash = $null
    try {
        $line = Invoke-Adb -Arguments @('-s', $Serial, 'shell', 'sha256sum', $remote)
        $remoteHash = ($line -split '\s+')[0].ToLowerInvariant()
    } catch {
        if ($VerifyOnly) { Write-Warning "Ausente: $($game.Name)"; continue }
    }

    if ($remoteHash) {
        if ($remoteHash -ne $game.Sha) { throw "Hash diferente no BTV; arquivo preservado: $remote" }
        Write-Host "Conferido: $($game.Name)"
        $verified++
        continue
    }

    $download = Join-Path $cache $game.Source
    Invoke-WebRequest -Uri ($sourceBase + $game.Source) -UseBasicParsing -TimeoutSec 30 -OutFile $download
    if ((Get-Item -LiteralPath $download).Length -ne $game.Bytes) { throw "Tamanho inválido: $($game.Source)" }
    $hash = (Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $game.Sha) { throw "Hash inválido: $($game.Source)" }
    Invoke-Adb -Arguments @('-s', $Serial, 'push', $download, $remote) | Out-Null
    $line = Invoke-Adb -Arguments @('-s', $Serial, 'shell', 'sha256sum', $remote)
    if (($line -split '\s+')[0].ToLowerInvariant() -ne $game.Sha) { throw "Cópia incompleta: $remote" }
    Write-Host "Instalado e conferido: $($game.Name)"
    $verified++
}

Write-Host "Jogos verificados: $verified/$($games.Count)"
if ($verified -ne $games.Count) { exit 1 }
