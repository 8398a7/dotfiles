wt() {
  local selected
  IFS= read -r -d '' selected < <(git wt --json | jq -j '.[] | select(.bare | not) | .path, "\u0000"' | fzf --read0 --print0) || return 0
  [[ -d "$selected" ]] || return 0
  git wt "$selected"
}
