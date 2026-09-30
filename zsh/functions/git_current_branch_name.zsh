git_current_branch_name() {
  git symbolic-ref --quiet --short HEAD
}
