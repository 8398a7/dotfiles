peco_ssh() {
  local res
  res=$(grep "Host " ~/.ssh/config | grep -v '*' | cut -b 6- | peco)
  if [ -n "$res" ]; then
    _peco_insert_command "ssh $res"
  fi
}
