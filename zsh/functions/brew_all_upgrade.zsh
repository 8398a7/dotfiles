brew_all_upgrade() {
  brew update && brew upgrade && brew cleanup
  brew upgrade --cask
}
