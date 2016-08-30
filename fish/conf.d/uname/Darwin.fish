if [ -d $HOME/.anyenv/bin ]
  set PATH $PATH $HOME/.anyenv/bin
  status --is-interactive; and source (anyenv init - | psub)
end

set -x GOPATH $HOME/go
if [ -d $GOPATH/bin ]
  set -x PATH $PATH $GOPATH/bin
end
if [ -d /usr/local/opt/libexec/bin ]
  set PATH $PATH /usr/local/opt/go/libexec/bin
end

if [ -d /usr/local/sbin ]
  set PATH $PATH /usr/local/sbin
end

# Added by the Heroku Toolbelt
if [ -d /usr/local/heroku/bin ]
  set PATH $PATH /usr/local/heroku/bin
end

# added by travis gem
if [ -f $HOME/.travis/travis.sh ]
  bass source "$HOME/.travis/travis.sh"
end

alias ls 'gls -F --color'
alias ctags /usr/local/bin/ctags
# postgres
set -x PGDATA /usr/local/var/postgres
alias psqlstart 'pg_ctl -l /usr/local/var/postgres/server.log start'
alias psqlstop 'pg_ctl -D /usr/local/var/postgres stop -s -m fast'
# show hidden-files
alias hfon 'defaults write com.apple.finder AppleShowAllFiles true|killall Finder'
# hidden hidden-files
alias hfoff 'defaults write com.apple.finder AppleShowAllFiles false|killall Finder'
