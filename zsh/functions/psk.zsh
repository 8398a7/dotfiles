psk() {
  local signal=TERM selected pid
  case "${1:-}" in --force) signal=KILL ;; '') ;; *) print -u2 'usage: psk [--force]'; return 1 ;; esac
  selected=$(ps ax -o pid=,time=,command= | fzf --query "${LBUFFER:-}") || return 0
  pid=${${(z)selected}[1]}
  [[ "$pid" == <-> ]] || return 0
  kill -s "$signal" -- "$pid"
}
