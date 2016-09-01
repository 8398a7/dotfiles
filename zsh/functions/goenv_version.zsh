goenv_version() {
  goenv version 2>/dev/null | awk '{print $1}'
}
