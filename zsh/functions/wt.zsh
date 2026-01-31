wt() {
  git wt "$(git wt | tail -n +2 | fzf | awk '{print $(NF-1)}')"
}
