function git_current_branch
  if echo $PWD | grep -q -E '\.git(/.*)?$'
    return
  end
  set -l symbolic_ref (git symbolic-ref HEAD 2> /dev/null)
  if [ -z $symbolic_ref ]
    return
  end

  set -l name (basename $symbolic_ref)
  set -l gitdir (git rev-parse --git-dir 2> /dev/null)
  set -l st (git status 2> /dev/null)

  set_color green
  if echo $st | grep -q -E 'nothing added'
    set_color yellow
  else if echo $st | grep -q -E 'modified'
    set_color red
  end
  printf " $name"
end
