fzf_ssh() {
  local selected
  [[ -r "$HOME/.ssh/config" ]] || return 0
  selected=$(awk 'tolower($1) == "host" { for (i=2; i<=NF; i++) if ($i ~ /^#/) break; else if ($i !~ /[*?!]/) print $i }' "$HOME/.ssh/config" | fzf --no-sort) || return 0
  [[ -n "$selected" ]] || return 0
  BUFFER="ssh -- ${(q)selected}"
  zle accept-line
}
zle -N fzf_ssh
