brew_cask_upgrade() {
  if echo $OSTYPE | grep -q darwin; then
    echo brew cask upgrade
    for c in `brew cask list`; do ! brew cask info $c | grep -qF "Not installed" || brew cask install $c; done
    echo brew cask cleanup
    brew cask cleanup
  else
    echo not darwin
  fi
}
