set PATH $PATH $HOME/.anyenv/bin
status --is-interactive; and source (anyenv init - | psub)
set PATH $PATH /usr/local/sbin
set PATH $PATH /usr/local/opt/go/libexec/bin
### Added by the Heroku Toolbelt
set PATH $PATH /usr/local/heroku/bin

alias ls 'gls -F --color'
# alias ctags="`brew --prefix`/bin/ctags"
# # postgres
# set -x PGDATA=/usr/local/var/postgres
# alias psqlstart='pg_ctl -l /usr/local/var/postgres/server.log start'
# alias psqlstop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'
# # added by travis gem
# [ -f $HOME/.travis/travis.sh ] and source $HOME/.travis/travis.sh
# # show hidden-files
# alias hfon="defaults write com.apple.finder AppleShowAllFiles true|killall Finder"
# # # hidden hidden-files
# alias hfoff="defaults write com.apple.finder AppleShowAllFiles false|killall Finder"

# # The next line updates PATH for the Google Cloud SDK.
# source $HOME/google-cloud-sdk/path.zsh.inc
# set -x GOPATH $HOME/go
# set -x PATH $GOPATH/bin $PATH
# . /usr/local/etc/profile.d/z.sh
