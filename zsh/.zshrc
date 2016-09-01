#  .------------------.
#  |  My zsh config   |
#  '------------------'
#      ^      (\_/)
#      '----- (O.o)
#             (> <)

# zplug {{{
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

source ~/.zplug/init.zsh
zplug "b4b4r07/emoji-cli", if:"which jq"
zplug "glidenote/hub-zsh-completion"
[ -d /usr/local/opt/coreutils/libexec/gnubin ] && export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
zplug 'joel-porquet/zsh-dircolors-solarized'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "motemen/ghq", as:command, from:gh-r, rename-to:ghq
zplug "mrowa44/emojify", as:command
zplug "peco/peco", as:command, from:gh-r
# zplug "rupa/z", use:z.sh
zplug "knu/z", use:z.sh, nice:10
zplug "stedolan/jq", as:command, from:gh-r, frozen:1
zplug "tcnksm/docker-alias", use:zshrc
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", nice:10

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose
# }}}
# load functions {{{
for function in $HOME/.zsh/functions/*.zsh; do
  source $function
done
# }}}
load_file $HOME/.zsh/external.zsh
# The next line updates PATH for the Google Cloud SDK.
load_file $HOME/google-cloud-sdk/path.zsh.inc
load_file $HOME/google-cloud-sdk/completion.zsh.inc

case ${OSTYPE} in
  # darwin {{{
  darwin*)
    if [ -d $HOME/.anyenv/bin ]; then
      export PATH=$HOME/.anyenv/bin:$PATH
      eval "$(anyenv init -)"
    fi
    expath /usr/local/sbin
    alias ctags=/usr/local/bin/ctags
    # postgres
    export PGDATA=/usr/local/var/postgres
    alias psqlstart='pg_ctl -l /usr/local/var/postgres/server.log start'
    alias psqlstop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'
    # show hidden-files
    alias hfon="defaults write com.apple.finder AppleShowAllFiles true|killall Finder"
    # # hidden hidden-files
    alias hfoff="defaults write com.apple.finder AppleShowAllFiles false|killall Finder"
    alias tailf='tail -f'
    ### Added by the Heroku Toolbelt
    expath /usr/local/heroku/bin
    # added by travis gem
    [ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh
    ;;
  # }}}
  linux*)
    ;;
esac
# Basic Configure {{{
# keybind
bindkey -e
# 256色対応
export TERM=xterm-256color
# 言語・文字コード設定
export LANG=ja_JP.UTF-8
# ビープ音を鳴らさない
setopt NO_BEEP
# 最近行ったディレクトリを記憶
setopt AUTO_PUSHD
# pushdの履歴を残さない
setopt PUSHD_IGNORE_DUPS
# リンクへ移動するとき実際のディレクトリへ移動
setopt CHASE_LINKS
# 大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# }}}
# Color {{{
# 色設定
# $fg[色名]/$bg[色名]$reset_color で色表示
autoload -U colors && colors

# 色定数
GREEN="%{$fg[green]%}"
GREEN_B="%{$fg_bold[green]%}"
BLUE="%{$fg[blue]%}"
BLUE_B="%{$fg_bold[blue]%}"
RED="%{$fg[red]%}"
RED_B="%{$fg_bold[red]%}"
CYAN="%{$fg[cyan]%}"
CYAN_B="%{$fg_bold[cyan]%}"
YELLOW="%{$fg[yellow]%}"
YELLOW_B="%{$fg_bold[yellow]%}"
MAGENTA="%{$fg[magenta]%}"
MAGENTA_B="%{$fg_bold[magenta]%}"
RESET="%{$reset_color%}"
# }}}
# Complement {{{
# コマンドの補完
autoload -U compinit && compinit
# 補完機能の拡張
setopt EXTENDED_GLOB
# TAB1回でリスト表示
setopt AUTO_LIST
# TAB連打でメニュー表示
setopt AUTO_MENU
# ドットファイルも対象に含める
setopt GLOBDOTS
# 語の途中でもカーソル位置で補完
setopt COMPLETE_IN_WORD
# =の後のパス名なども補完
setopt MAGIC_EQUAL_SUBST
# 補完候補を詰めて表示
setopt LIST_PACKED
# 候補一覧選択を横進みにする
setopt LIST_ROWS_FIRST
# 補完対象の一覧を上下左右に移動できる
zstyle ':completion:*:default' menu select=2
# 補間対象一覧に色をつける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# }}}
# History {{{
# ヒストリファイルの指定
HISTFILE=$HOME/.zsh_histfile
# 履歴件数の指定
HISTSIZE=10000000
SAVEHIST=10000000
# 重複した履歴を保存しない
setopt HIST_IGNORE_DUPS
# 履歴を共有
setopt SHARE_HISTORY
# 余分な空白を削除して履歴を保存
setopt HIST_REDUCE_BLANKS
# 入力の途中でもヒストリ検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
# }}}
# Alias {{{
alias ls="ls -F --color"
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -al"
alias lr="ls -R"
alias rb="ruby"
alias gst="git status"
alias gch="git checkout"
alias gbr="git branch"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias gla="git log --graph --all --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias at="tmux attach -t"
alias ks="tmux kill-session -t"
alias tls="tmux ls"
alias trs="tmux rename -t"
alias be="bundle exec"
alias rs="rails s -b 0.0.0.0"
alias rc="rails c"
alias pdep="bundle exec cap production deploy"
alias sdep="bundle exec cap staging deploy"
alias -g B='"$(git_current_branch_name)"'
alias gpl='git pull origin "$(git_current_branch_name)"'
alias gps='git push origin "$(git_current_branch_name)"'
if [ -x /usr/local/bin/vim ]; then
  alias vi=/usr/local/bin/vim
  export EDITOR=vim
fi
if type nvim > /dev/null; then
  alias vim=nvim
  export EDITOR=nvim
fi
alias py=python
# }}}
# Prompt {{{
autoload -Uz VCS_INFO_get_data_git && VCS_INFO_get_data_git 2> /dev/null
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt PROMPT_SUBST
PROMPT_GIT='`git_current_branch`'
RBENV=" r:$(rbenv_version)"
CRENV=" c:$(crenv_version)"
NODENV=" n:$(nodenv_version)"
# GOENV=" g:$(goenv_version)"
# JENV=" j:$(jenv_version)"
# EXENV=" e:$(exenv_version)"
USER_HOST="$(fg256 075 '%n')${YELLOW_B}@${RESET}$(fg256 120 '%m')"
PROMPT_ROLE="${CYAN_B}%(!.#.$) >${RESET}"
PROMPT="${USER_HOST} $(fg256 214 '%~')${PROMPT_GIT}$(fg256 169 ${RBENV})$(fg256 003 ${CRENV})$(fg256 063 ${EXENV})$(fg256 222 ${GOENV})$(fg256 047 ${NODENV})$(fg256 012 ${JENV})
${PROMPT_ROLE} "
# }}}
# Export {{{
export GOPATH=$HOME/.go
expath $GOPATH/bin
export FZF_COMPLETION_TRIGGER="~~"
export FZF_DEFAULT_OPTS="--extended --cycle --reverse --exact"
# }}}
# Bindkey {{{
bindkey '^r' fzf_history_search
bindkey '^j' peco_z_search
# }}}
