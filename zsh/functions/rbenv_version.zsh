rbenv_version() {
  rbenv version 2>/dev/null | awk '{print $1}'
}

