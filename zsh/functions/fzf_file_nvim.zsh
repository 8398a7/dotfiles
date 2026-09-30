fzf_file_nvim() {
  local selected
  IFS= read -r -d '' selected < <(fd --type f --hidden --exclude .git --print0 | fzf --read0 --print0 --no-sort) || return 0
  [[ -n "$selected" ]] || return 0
  BUFFER="nvim -- ${(q)selected}"
  zle accept-line
}
zle -N fzf_file_nvim
