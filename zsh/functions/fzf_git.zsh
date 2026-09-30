_fzf_git_ref() {
  local selected ref kind
  local -a options=(--no-multi --delimiter=$'\t' --with-nth=1,2)
  [[ "${1:-}" == preview ]] && options+=(--preview='git --no-pager log -150 --oneline {2} --')
  selected=$(git for-each-ref --sort=-committerdate \
    --format='%(if)%(symref)%(then)%(else)%(refname:strip=1)%09%(refname)%(end)' \
    refs/heads refs/remotes refs/tags | sed '/^$/d' | fzf "${options[@]}") || return 0
  [[ -n "$selected" ]] || return 0
  ref=${selected#*$'\t'}
  case "$ref" in
    refs/heads/*) git switch -- "${ref#refs/heads/}" ;;
    refs/remotes/*) git switch --track -- "$ref" ;;
    refs/tags/*) git switch --detach -- "$ref" ;;
  esac
}
fzf_git() { _fzf_git_ref; }
fbr() { _fzf_git_ref; }
fco() { _fzf_git_ref; }
fco_preview() { _fzf_git_ref preview; }
