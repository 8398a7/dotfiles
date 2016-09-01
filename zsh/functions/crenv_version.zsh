crenv_version() {
  crenv version 2>/dev/null | awk '{print $1}'
}
