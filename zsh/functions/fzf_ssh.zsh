fzf_ssh() {
  local res=$(awk '/^Host / && !/\*/ {print $2}' ~/.ssh/config | fzf --no-sort)
  if [ -n "$res" ]; then
    BUFFER+="ssh $res"
    zle accept-line
  else
    zle clear-screen
    return 1
  fi
}
zle -N fzf_ssh
