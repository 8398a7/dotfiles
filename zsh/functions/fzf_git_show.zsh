fzf_git_show() {
  local selected hash
  selected=$(git --no-pager log --oneline --decorate=full | fzf) || return 0
  [[ -n "$selected" ]] || return 0
  hash=${selected%% *}
  _insert_command "git show ${(q)hash} --"
}
