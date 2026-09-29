ghq_cd() {
  local root selected
  root=$(ghq root) || return
  selected=$(ghq list | fzf --no-sort) || return 0
  [[ -n "$selected" ]] || return 0
  builtin cd -- "$root/$selected"
}
