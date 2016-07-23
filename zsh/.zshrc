export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH=$PATH:/usr/local/Cellar/git/2.9.0/share/git-core/contrib/diff-highlight
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
source ~/.zsh/.zshmain
alias ctags="`brew --prefix`/bin/ctags"

# postgres
export PGDATA=/usr/local/var/postgres
alias psqlstart='pg_ctl -l /usr/local/var/postgres/server.log start'
alias psqlstop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

# other
alias py='python'
alias tailf='tail -f'
alias n='nvim'

# added by travis gem
[ -f /Users/husq/.travis/travis.sh ] && source /Users/husq/.travis/travis.sh

# show hidden-files
alias hfon="defaults write com.apple.finder AppleShowAllFiles true|killall Finder"
# # hidden hidden-files
alias hfoff="defaults write com.apple.finder AppleShowAllFiles false|killall Finder"

# z command
. /usr/local/etc/profile.d/z.sh
function _Z_precmd {
  z --add "$(pwd -P)" 61 }
precmd_functions=($precmd_functions _Z_precmd)

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
source '/Users/husq/google-cloud-sdk/path.zsh.inc'

# The next line enables shell command completion for gcloud.
source '/Users/husq/google-cloud-sdk/completion.zsh.inc'
