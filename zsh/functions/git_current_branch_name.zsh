git_current_branch_name() {
  git rev-parse --abbrev-ref HEAD
}
