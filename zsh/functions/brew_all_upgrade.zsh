brew_all_upgrade() {
  command -v brew >/dev/null || return 1
  brew update && brew upgrade && brew cleanup
}
