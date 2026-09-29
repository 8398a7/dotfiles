fzf_z_search() {
  local selected data=${_Z_DATA:-$HOME/.z}
  [[ -r "$data" ]] || return 0
  # The z database stores path|rank|timestamp; do not parse display columns.
  selected=$(awk -F '|' '{print $2 "\t" $1}' "$data" | sort -nr | cut -f2- | fzf --no-sort --query="$LBUFFER") || return 0
  [[ -d "$selected" ]] || return 0
  BUFFER="cd -- ${(q)selected}"
  zle accept-line
}
zle -N fzf_z_search
