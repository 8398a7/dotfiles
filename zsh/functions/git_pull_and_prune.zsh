git_pull_and_prune() {
  git symbolic-ref --quiet HEAD >/dev/null || return 1
  # Respect the branch's configured upstream, including non-origin remotes.
  git pull || return
  git fetch --prune --tags --all || return
  "${XDG_CONFIG_HOME:-$HOME/.config}/git/bin/delete-merged-branches"
}
