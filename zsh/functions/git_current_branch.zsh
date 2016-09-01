git_current_branch() {
  local name st color gitdir action
  if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
    return
  fi
  name=$(basename "`git symbolic-ref HEAD 2> /dev/null`")
  if [[ -z $name ]]; then
    return
  fi

  gitdir=`git rev-parse --git-dir 2> /dev/null`
  action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    color=${GREEN}
  elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
    color=${YELLOW}
  elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
    color=${RED_B}
  else
    color=${RED}
  fi
  echo "${color} \uE0A0 ${name}${action}${RESET}"
}
