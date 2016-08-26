set fish_greeting
eval (command dircolors -c $HOME/dotfiles/fish/.dir_colors)

switch (uname)
case Darwin
  source $HOME/.config/fish/conf.d/darwin.fish
  bass source "$HOME/google-cloud-sdk/path.bash.inc"
  bass source "$HOME/google-cloud-sdk/completion.bash.inc"
case Linux
  source $HOME/.zsh.d/z/z.sh
  source $HOME/.zsh/.zshmain
end

# other
alias vi /usr/local/bin/vim
alias vim nvim
alias py 'python'
alias tailf 'tail -f'
alias rmdocker 'docker rm (docker ps -aq)'

alias ls 'ls -F --color'
alias ll 'ls -l'
alias la 'ls -a'
alias lla 'ls -al'
alias lr 'ls -R'
alias rb 'ruby'

alias gst 'git status'
alias gch 'git checkout'
alias gbr 'git branch'
alias gpl 'git pull origin (git_current_branch_name)'
alias gps 'git push origin (git_current_branch_name)'
alias glg "git log --graph --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias gla "git log --graph --all --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"

alias at 'tmux attach -t'
alias ks 'tmux kill-session -t'
alias tls 'tmux ls'
alias trs 'tmux rename -t'

alias be 'bundle exec'
alias rs 'rails s -b 0.0.0.0'
alias rc 'rails c'
alias pdep 'bundle exec cap production deploy'
alias sdep 'bundle exec cap staging deploy'
