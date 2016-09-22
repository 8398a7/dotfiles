brew_upgrade() {
  if echo $OSTYPE | grep -q darwin; then
    echo brew update
    brew update
    echo brew upgrade
    brew upgrade
    echo brew cleanup
    brew cleanup
  else
    echo not darwin
  fi
}
