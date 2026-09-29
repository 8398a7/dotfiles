cd_gitroot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  builtin cd -- "$root"
}
