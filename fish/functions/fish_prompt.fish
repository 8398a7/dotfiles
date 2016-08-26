function fish_prompt
  set last_status $status

  printf '%s ' (user_at_host)
  set_color e38f26
  printf '%s' (prompt_pwd)

  printf ' %s' (git_current_branch)

  set_color ee2c36
  printf ' r:%s' (rbenv_version)
  set_color yellow
  printf ' c:%s' (crenv_version)
  set_color 2bb858
  printf ' n:%s' (nodenv_version)

  if test $last_status -eq 0
    set_color green
  else
    set_color red
  end
  echo ' status'

  set_color cyan
  echo -n '$ > '

  set_color normal
end
