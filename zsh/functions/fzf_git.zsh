fzf_git() {
  if [ "$1" = 'show' ]; then
    # fshow - git commit browser
    # ref: https://github.com/junegunn/fzf/wiki/Examples
    shift
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --tiebreak=index \
      --bind "ctrl-m:execute:
    sh -c \"echo {} | grep -o '[a-f0-9]\{7\}' | xargs -I _ git show --color=always _ | diff-highlight | less -RX\""
  else
    # fetch git commit hash
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --tiebreak=index |
    head -1 | grep -o '[a-f0-9]\{7\}'
  fi
}