function git_current_branch
  if echo $PWD | grep -q -E '\.git(/.*)?$'
    return
  end
  set -l name (git_current_branch_name 2> /dev/null)
  if [ -z $name ]
    return
  end

  set -l gitdir (git rev-parse --git-dir 2> /dev/null)
  set -l st (git status 2> /dev/null)

  set_color green
  if echo $st | grep -q -E 'nothing added'
    set_color yellow
  else if echo $st | grep -q -E 'modified'
    set_color red
  else if echo $st | grep -q -E 'deleted'
    set_color red
  else if echo $st | grep -q -E 'Changes to be committed'
    set_color red
  end
  printf " $name"
end
