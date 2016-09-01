load_file() {
  if [ -r $1 ]; then
    source $1
  fi
}
