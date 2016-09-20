fzf_tree_vim() {
  local SELECTED_FILE
  if [ -r ".gitignore" ]; then
    local ignores="$(cat .gitignore | tr '\n' '|' | sed '$s/.$//')"
    SELECTED_FILE=$(tree --charset=o -f -I $ignores | fzf --no-sort | tr -d '\||`|-' | xargs echo)
  else
    SELECTED_FILE=$(tree --charset=o -f | fzf --no-sort | tr -d '\||`|-' | xargs echo)
  fi
  echo $SELECTED_FILE
  BUFFER="vim $SELECTED_FILE"
  zle accept-line
}
zle -N fzf_tree_vim
