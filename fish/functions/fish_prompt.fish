function fish_prompt
  set last_status $status

  printf '%s ' (user_at_host)
  printf '%s ' (status_mark $last_status)

  set_color e38f26
  printf '%s' (prompt_pwd)

  printf ' %s' (git_current_branch)

  set_color ee2c36
  printf ' r:%s' (rbenv_version)
  set_color yellow
  printf ' c:%s' (crenv_version)
  set_color 2bb858
  printf ' n:%s\n' (nodenv_version)

  set_color cyan --bold
  echo -n '$ > '

  set_color normal
end
