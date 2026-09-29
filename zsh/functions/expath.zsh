expath() {
  [[ -d "$1" ]] || return 0
  typeset -gU path
  path=("$1" $path)
}
