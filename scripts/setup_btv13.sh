#!/usr/bin/env bash
# Copia a lista curta validada sem substituir o fornecedor de 29 canais do OpenTV.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 IP:PORTA_ADB" >&2
  exit 2
fi

serial=$1
adb_bin=${ADB_BIN:-adb}
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root_dir=$(cd -- "$script_dir/.." && pwd)
playlist="$root_dir/config/btv13_custom.m3u"
remote=/sdcard/Download/BTV13_ESSENCIAIS.m3u

command -v "$adb_bin" >/dev/null || { echo "ADB não encontrado no PATH." >&2; exit 1; }
[[ -f "$playlist" ]] || { echo "Lista local ausente: $playlist" >&2; exit 1; }
[[ $(head -n 1 "$playlist") == '#EXTM3U' ]] || { echo "Cabeçalho M3U inválido." >&2; exit 1; }
[[ $(grep -c '^#EXTINF:' "$playlist") -eq 10 ]] || { echo "A lista não tem 10 canais." >&2; exit 1; }
if grep -Eq '^http://|^rtmp://' "$playlist"; then
  echo "A lista contém URL não HTTPS." >&2
  exit 1
fi

state=$("$adb_bin" -s "$serial" get-state)
[[ "$state" == device ]] || { echo "BTV não autorizado/conectado: $state" >&2; exit 1; }

if "$adb_bin" -s "$serial" shell test -f "$remote"; then
  backup_dir="$root_dir/backups"
  mkdir -p "$backup_dir"
  backup="$backup_dir/BTV13_ESSENCIAIS_$(date +%Y%m%d_%H%M%S).m3u"
  "$adb_bin" -s "$serial" pull "$remote" "$backup"
  echo "Cópia anterior salva em: $backup"
fi

"$adb_bin" -s "$serial" push "$playlist" "$remote"
local_bytes=$(wc -c < "$playlist" | tr -d ' ')
remote_bytes=$("$adb_bin" -s "$serial" shell wc -c "$remote" | awk '{print $1}')
[[ "$local_bytes" == "$remote_bytes" ]] || { echo "Falha na conferência de tamanho." >&2; exit 1; }

echo "Lista de 10 canais copiada e conferida: $remote ($remote_bytes bytes)"
echo "O fornecedor atual de 29 canais não foi substituído."
echo "Para adicionar a lista curta como fonte no OpenTV, use:"
echo "https://raw.githubusercontent.com/WingCell/BTV13-Manager/main/config/btv13_custom.m3u"
