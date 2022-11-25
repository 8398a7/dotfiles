fzf_git_show() {
  local res
  res=$(git log --oneline --decorate=full | fzf | awk '{print $1}')
  if [ -n "$res" ]; then
    _insert_command "git show $res"
  fi
}
