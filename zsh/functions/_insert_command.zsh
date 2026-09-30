_insert_command() {
  if [[ -o zle ]] && zle; then
    BUFFER=$1
    CURSOR=$#BUFFER
    zle reset-prompt
  else
    print -z -- "$1"
  fi
}
