fzf-fd() {
  local selected
  IFS= read -r -d '' selected < <(fd --type d --hidden --exclude .git --print0 | fzf --read0 --print0 --query="$LBUFFER") || return 0
  [[ -n "$selected" ]] || return 0
  BUFFER="cd -- ${(q)selected}"
  zle accept-line
}
zle -N fzf-fd
