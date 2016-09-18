peco_git_show() {
  local res
  res=$(git log --oneline --decorate=full | peco | awk '{print $1}')
  if [ -n "$res" ]; then
    _peco_insert_command "git show $res"
  fi
}
