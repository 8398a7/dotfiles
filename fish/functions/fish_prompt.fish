# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red
set __fish_git_prompt_set_color blue

# Status Chars
set __fish_git_prompt_char_dirtystate ' '
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'

function fish_prompt
  set last_status $status

  printf '%s ' (user_at_host)
  set_color e38f26
  printf '%s' (prompt_pwd)

  set_color ee2c36
  printf ' r:%s' (rbenv_version)
  set_color yellow
  printf ' c:%s' (crenv_version)
  set_color 2bb858
  printf ' n:%s' (nodenv_version)

  set_color normal
  echo (__fish_git_prompt)

  set_color cyan
  echo -n '$ > '

  set_color normal
end
