fzf_z_search() {
  local res=$(z | sort -rn | cut -c 12- | fzf --no-sort)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
  else
    zle clear-screen
    return 1
  fi
}
zle -N fzf_z_search
