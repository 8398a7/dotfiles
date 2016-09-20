git_pull_and_pull() {
  git pull origin $(git_current_branch_name)
  git fetch --prune --tags --all && git branch --merged | egrep -v '^\*|\smaster$|\sdevelop$' | xargs git branch -d
}
