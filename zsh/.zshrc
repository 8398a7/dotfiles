case ${OSTYPE} in
  darwin*)
    source $HOME/.zsh/.zshosx
    source $HOME/.zsh/.zshmain
    # # The next line enables shell command completion for gcloud.
    # required zshmain
    source $HOME/google-cloud-sdk/completion.zsh.inc
    ;;
  linux*)
    source $HOME/.zsh.d/z/z.sh
    source $HOME/.zsh/.zshmain
    ;;
esac

# other
alias vi=/usr/local/bin/vim
alias vim=nvim
alias py='python'
alias tailf='tail -f'
alias rmdocker="docker rm $(docker ps -aq)"

source ~/.zplug/init.zsh
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", nice:10
zplug "rupa/z", use:z.sh
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose
