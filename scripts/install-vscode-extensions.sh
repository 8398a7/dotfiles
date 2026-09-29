#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
command -v code >/dev/null || { printf 'VSCode CLI (code) が必要です\n' >&2; exit 1; }
while IFS= read -r extension || [[ -n "$extension" ]]; do
  [[ -z "$extension" || "$extension" == \#* ]] && continue
  printf '%s installing...\n' "$extension"
  code --install-extension "$extension"
done < "$root/vscode/extensions.txt"
