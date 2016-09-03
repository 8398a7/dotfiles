function peco_tree_vim(){
  local SELECTED_FILE=$(tree --charset=o -f | peco | tr -d '\||`|-' | xargs echo)
  BUFFER="vim $SELECTED_FILE"
  zle accept-line
}
zle -N peco_tree_vim
