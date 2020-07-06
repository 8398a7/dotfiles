#  .------------------.
#  |  My zsh config   |
#  '------------------'
#      ^      (\_/)
#      '----- (O.o)
#             (> <)
# rm -f ~/.zcompdump; compinit
stty stop undef
stty start undef

# load functions {{{
for function in $HOME/.zsh/functions/*.zsh; do
  source $function
done
# }}}
load_file $HOME/.zsh/external.zsh
load_file $HOME/.zsh/secret.zsh
# zplug {{{
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh
fi

source ~/.zplug/init.zsh
zplug "b4b4r07/emoji-cli", on:"junegunn/fzf-bin", if:'(( $+commands[jq] ))'
zplug "b4b4r07/enhancd", use:init.sh
zplug 'b4b4r07/fzf-powertools', as:command, use:'re'
zplug "github/hub", as:command, from:gh-r
expath /usr/local/opt/coreutils/libexec/gnubin
zplug 'joel-porquet/zsh-dircolors-solarized'
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:"fzf", frozen:1
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
zplug "mackerelio/mkr", as:command, from:gh-r
zplug "monochromegane/the_platinum_searcher", as:command, from:gh-r, rename-to:'pt'
zplug "x-motemen/ghq", as:command, from:gh-r, rename-to:ghq
zplug "mrowa44/emojify", as:command
zplug "peco/peco", as:command, from:gh-r, frozen:1
# zplug "rupa/z", use:z.sh
zplug "reorx/httpstat", as:command, use:'(httpstat).py', rename-to:'$1', if:'(( $+commands[python] ))'
zplug "knu/z", use:z.sh, defer:2
zplug "sharkdp/bat", from:gh-r, as:command
zplug "stedolan/jq", from:gh-r, as:command
zplug "supercrabtree/k"
zplug "tcnksm/docker-alias", use:zshrc
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "jonmosco/kube-ps1"
zplug "ahmetb/kubectx", as:command, use:kubectx
zplug "ahmetb/kubectx", as:command, use:kubens

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# Then, source plugins and add commands to $PATH
zplug load
# zsh-syntax-highlighting {{{
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES
# エイリアスコマンドのハイライト
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
# 存在するパスのハイライト
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
# グロブ
ZSH_HIGHLIGHT_STYLES[globbing]='none'
# マッチしない括弧
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold'
# 括弧の階層
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=blue,bold'
# カーソルがある場所の括弧にマッチする括弧
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'
# }}}
setupsolarized
export ENHANCD_FILTER=fzf
# }}}

# The next line updates PATH for the Google Cloud SDK.
load_file $HOME/google-cloud-sdk/path.zsh.inc
load_file $HOME/google-cloud-sdk/completion.zsh.inc

case $OSTYPE in
  # darwin {{{
  darwin*)
    if [ -d $HOME/.anyenv ]; then
      eval "$(anyenv init -)"
    fi
    expath /usr/local/sbin
    expath /usr/local/opt/openssl/bin
    # postgres
    export PGDATA=/usr/local/var/postgres
    alias psqlstart="pg_ctl -l /usr/local/var/postgres/server.log start"
    alias psqlstop="pg_ctl -D /usr/local/var/postgres stop -s -m fast"
    # show hidden-files
    alias hfon="defaults write com.apple.finder AppleShowAllFiles true|killall Finder"
    # # hidden hidden-files
    alias hfoff="defaults write com.apple.finder AppleShowAllFiles false|killall Finder"
    ;;
  # }}}
  linux*)
    ;;
esac
# basic configure {{{
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
# コマンド実行時にコメントを残せるようにする
setopt interactivecomments
# 大文字小文字を区別しない
zstyle ":completion:*" matcher-list "m:{a-z}={A-Z}"
# }}}
# color {{{
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
# complement {{{
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
zstyle ":completion:*:default" menu select=2
# 補間対象一覧に色をつける
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}
# }}}
# history {{{
# ヒストリファイルの指定
HISTFILE=$HOME/.zsh_histfile
# 履歴件数の指定
HISTSIZE=10000000
SAVEHIST=10000000
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups

# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify

# 余分な空白は詰めて記録
setopt hist_reduce_blanks

# 古いコマンドと同じものは無視
setopt hist_save_no_dups

# historyコマンドは履歴に登録しない
setopt hist_no_store

# 補完時にヒストリを自動的に展開
setopt hist_expand

# 履歴をインクリメンタルに追加
setopt inc_append_history

# インクリメンタルからの検索
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
# }}}
# alias {{{
alias rb=ruby
alias vi=vim
alias py=python
alias cat='bat -p'
alias tailf='tail -f'
alias grep="grep --color=auto"
alias ls="ls -F --color"
alias ll="ls -al"
alias la="ls -a"
alias lr="ls -R"
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
alias gpl="git_pull_and_pull"
alias gps='git push origin "$(git_current_branch_name)"'
alias gf="fzf_git"
alias g='cd $(ghq root)/$(ghq list | fzf --no-sort)'
alias gh='hub browse $(ghq list | fzf --no-sort | cut -d "/" -f 2,3)'
alias gr="cd_gitroot"
# peco
alias pss="peco_ssh"
alias pgs="peco_git_show"
# }}}
# prompt {{{
load_file $HOME/.zplug/repos/jonmosco/kube-ps1/kube-ps1.sh
autoload -Uz VCS_INFO_get_data_git && VCS_INFO_get_data_git 2> /dev/null
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt PROMPT_SUBST
PROMPT_GIT='`git_current_branch_prompt`'
USER_HOST="$(fg256 075 '%n')${YELLOW_B}@${RESET}$(fg256 120 '%m')"
PROMPT_ROLE="${CYAN_B}%(!.#.$) >${RESET}"
K8S_PROMPT='$(kube_ps1)'
PROMPT="${USER_HOST} $(fg256 214 '%~')${PROMPT_GIT} ${K8S_PROMPT}
${PROMPT_ROLE} "
# }}}
# export {{{
export GOPATH=$HOME/go
expath $GOPATH/bin
expath $GOPATH/$(cat $HOME/.anyenv/envs/goenv/version)/bin
expath $GOPATH/src/github.com/8398a7/tools/bin
expath $HOME/.yarn/bin
export FZF_COMPLETION_TRIGGER="~~"
export FZF_DEFAULT_OPTS="--extended --cycle --reverse --exact"
eval "$(direnv hook zsh)"
export CLOUDSDK_PYTHON=python3
export EDITOR=vim
# }}}
# bindkey {{{
bindkey "^r" fzf_select_history
bindkey "^j" fzf_z_search
bindkey "^o" complete_mackerel_host_ip
bindkey "^s" fzf_ssh
# bindkey "^e" emoji::cli
# }}}

if [ -f "/usr/local/bin/kubectl" ]; then source <(kubectl completion zsh); fi
