jenv_version() {
  jenv version 2>/dev/null | awk '{print $1}'
}
