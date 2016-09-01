expath() {
  if [ -d $1 ]; then
    export PATH=$PATH:$1
  fi
}
