exenv_version() {
  exenv version 2>/dev/null | awk '{print $1}'
}
