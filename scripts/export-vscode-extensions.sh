#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
command -v code >/dev/null || { printf 'VSCode CLI (code) が必要です\n' >&2; exit 1; }
temporary=$(mktemp "$root/vscode/extensions.txt.XXXXXX")
trap 'rm -f -- "$temporary" "$temporary.sorted"' EXIT
code --list-extensions > "$temporary"
LC_ALL=C sort -fu "$temporary" > "$temporary.sorted"
mv -- "$temporary.sorted" "$root/vscode/extensions.txt"
