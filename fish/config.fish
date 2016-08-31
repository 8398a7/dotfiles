set fish_greeting
load_file $HOME/dotfiles/fish/external.fish

switch (uname)
case Darwin
  source $HOME/.config/fish/conf.d/uname/Darwin.fish
  eval (command gdircolors -c "$HOME/dotfiles/fish/.dir_colors")
case Linux
  source $HOME/.config/fish/conf.d/uname/Linux.fish
  eval (command dircolors -c "$HOME/dotfiles/fish/.dir_colors")
end

if [ -e $HOME/google-cloud-sdk ]
  bass source "$HOME/google-cloud-sdk/path.bash.inc"
  bass source "$HOME/google-cloud-sdk/completion.bash.inc"
end

set -x FZF_DEFAULT_OPTS "--extended --cycle --reverse --exact"
if type -qa nvim
  set -x EDITOR nvim
else if type -qa vim
  set -x EDITOR vim
end
set -x HISTSIZE 10000000
set -x SAVEHIST 10000000

# alias {{{
if type -qa vim
  alias vi (which vim)
end
if type -qa vim
  alias vim nvim
end
alias py python
alias tailf 'tail -f'
alias rmdocker 'docker rm (docker ps -aq)'

alias lr 'ls -R'
alias rb ruby
# git {{{
alias gst 'git status'
alias gch 'git checkout'
alias gbr 'git branch'
alias gpl 'git pull origin (git_current_branch_name)'
alias gps 'git push origin (git_current_branch_name)'
alias glg "git log --graph --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias gla "git log --graph --all --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
# }}}
# tmux {{{
alias at 'tmux attach -t'
alias ks 'tmux kill-session -t'
alias tls 'tmux ls'
alias trs 'tmux rename -t'
# }}}
# rails {{{
alias be 'bundle exec'
alias rs 'rails s -b 0.0.0.0'
alias rc 'rails c'
alias pdep 'bundle exec cap production deploy'
alias sdep 'bundle exec cap staging deploy'
# }}}
# }}}
