get_ssid_tmux() {
  local ssid="$(get_ssid)"
  if [ -n "$ssid" ]; then
    echo "#[bg=default,fg=colour014,bold] $ssid #[default]"
  else
    echo "#[bg=default,fg=red] ✘ #[default]"
  fi
}
