git_current_branch_name() {
  git branch | grep '^\*' | sed 's/^\* *//'
}
