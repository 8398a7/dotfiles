peco_tree_vim() {
  local SELECTED_FILE
  if [ -r ".gitignore" ]; then
    local ignores="$(cat .gitignore | tr '\n' '|' | sed '$s/.$//')"
    SELECTED_FILE=$(tree --charset=o -f -I $ignores | peco | tr -d '\||`|-' | xargs echo)
  else
    SELECTED_FILE=$(tree --charset=o -f | peco | tr -d '\||`|-' | xargs echo)
  fi
  echo $SELECTED_FILE
  BUFFER="vim $SELECTED_FILE"
  zle accept-line
}
zle -N peco_tree_vim
