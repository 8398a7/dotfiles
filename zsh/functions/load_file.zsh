load_file() {
  [[ -r "$1" ]] && source "$1"
  return 0
}
