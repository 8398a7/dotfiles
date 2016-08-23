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

# z command
function _Z_precmd { z --add "$(pwd -P)" 61 }
precmd_functions=($precmd_functions _Z_precmd)
