git_current_branch_prompt() {
  local name changes color gitdir action=''
  gitdir=$(git rev-parse --git-dir 2>/dev/null) || return 0
  name=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    name=$(git rev-parse --short HEAD 2>/dev/null) || return 0
  changes=$(git status --porcelain=v1 2>/dev/null) || return 0
  color=${GREEN:-'%F{green}'}
  [[ -n "$changes" ]] && color=${YELLOW:-'%F{yellow}'}
  [[ "$changes" == *$'\n?? '* || "$changes" == '?? '* ]] && color=${RED:-'%F{red}'}
  if [[ -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" ]]; then
    action='(rebase)'
  elif [[ -f "$gitdir/MERGE_HEAD" ]]; then
    action='(merge)'
  elif [[ -f "$gitdir/CHERRY_PICK_HEAD" ]]; then
    action='(cherry-pick)'
  fi
  # Percent signs in refs must be literal in zsh's prompt language.
  name=${name//\%/%%}
  print -r -- "${color} git:${name}${action}${RESET:-'%f'}"
}
