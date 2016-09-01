nodenv_version() {
  nodenv version 2>/dev/null | awk '{print $1}'
}

