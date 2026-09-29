# Interactive configuration. Locate this checkout through the .zshrc symlink.
[[ -o interactive ]] || return 0
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
typeset -U path fpath
typeset dotfiles_zsh_dir=${${(%):-%N}:A:h}
for dotfiles_function in "$dotfiles_zsh_dir"/functions/*.zsh(N); do
  source "$dotfiles_function"
done
unset dotfiles_function

# Put tool entry points on PATH before activating integrations.
expath "$HOME/.local/bin"
export BUN_INSTALL=${BUN_INSTALL:-$HOME/.bun}
expath "$BUN_INSTALL/bin"
expath "${GOPATH:-$HOME/go}/bin"
load_file "$HOME/.cargo/env"
expath "$HOME/.antigravity/antigravity/bin"
if [[ "$OSTYPE" == darwin* ]]; then
  expath /opt/homebrew/bin
  expath /usr/local/bin
  if command -v brew >/dev/null; then
    expath "$(brew --prefix coreutils)/libexec/gnubin"
  fi
  alias hfon='defaults write com.apple.finder AppleShowAllFiles true && killall Finder'
  alias hfoff='defaults write com.apple.finder AppleShowAllFiles false && killall Finder'
fi
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi
load_file "$HOME/google-cloud-sdk/path.zsh.inc"
load_file "$HOME/google-cloud-sdk/completion.zsh.inc"
load_file "$dotfiles_zsh_dir/external.zsh"

bindkey -e
setopt NO_BEEP AUTO_PUSHD PUSHD_IGNORE_DUPS CHASE_LINKS INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB AUTO_LIST AUTO_MENU GLOBDOTS COMPLETE_IN_WORD MAGIC_EQUAL_SUBST
setopt LIST_PACKED LIST_ROWS_FIRST
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Preserve the terminal's TERM and the user's locale.
if [[ -z "${LANG:-}" ]]; then
  if locale -a 2>/dev/null | command grep -qi '^C\.utf'; then
    export LANG=C.UTF-8
  elif locale -a 2>/dev/null | command grep -qi '^en_US\.utf'; then
    export LANG=en_US.UTF-8
  else
    export LANG=C
  fi
fi

export FZF_COMPLETION_TRIGGER='~~'
export FZF_DEFAULT_OPTS='--extended --cycle --reverse --exact'
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'
# plugins.toml adds completion directories, runs compinit, then loads plugins.
if command -v sheldon >/dev/null; then
  eval "$(sheldon source)"
fi
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi
if command -v git-wt >/dev/null; then
  eval "$(git-wt --init zsh)"
fi
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

HISTFILE=${HISTFILE:-$HOME/.zsh_histfile}
HISTSIZE=${DOTFILES_HISTSIZE:-200000}
SAVEHIST=${DOTFILES_SAVEHIST:-100000}
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_VERIFY HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS HIST_NO_STORE INC_APPEND_HISTORY
# Ctrl-R is provided by fzf, falling back to zsh's search when fzf is absent.
command -v fzf >/dev/null || bindkey '^r' history-incremental-search-backward
bindkey '^j' fzf_z_search
bindkey '^s' fzf_ssh
bindkey '^n' fzf-fd

alias rb=ruby
alias vi=nvim
alias vim=nvim
alias cx='codex --dangerously-bypass-approvals-and-sandbox'
alias py=python3
command -v bat >/dev/null && alias cat='bat -p'
alias tailf='tail -f'
if [[ "$OSTYPE" == darwin* ]] && ! command -v gls >/dev/null; then
  alias ls='ls -FG'
else
  alias ls='ls -F --color=auto'
fi
alias ll='ls -al'
alias la='ls -a'
alias lr='ls -R'
alias gr=cd_gitroot
alias fgs=fzf_git_show
alias glg="git log --graph --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias gla="git log --graph --all --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%C(yellow)%d%Creset' --abbrev-commit --date=relative"
alias gpl=git_pull_and_prune
alias gps='git push'
alias gf=fzf_git
alias g=ghq_cd
alias -g B='"$(git_current_branch_name)"'
export EDITOR=nvim
export VISUAL=nvim
export CLOUDSDK_PYTHON=python3
load_file "$BUN_INSTALL/_bun"

# Compute Git status once per command, not whenever the prompt is redrawn.
GREEN='%F{green}' YELLOW='%F{yellow}' RED='%F{red}' RESET='%f'
__dotfiles_prompt_git() { DOTFILES_GIT_PROMPT=$(git_current_branch_prompt); }
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd __dotfiles_prompt_git
add-zsh-hook precmd __dotfiles_prompt_git
setopt PROMPT_SUBST
PROMPT='%F{75}%n%f%F{yellow}@%f%F{120}%m%f %F{214}%~%f${DOTFILES_GIT_PROMPT}'$'\n''%F{cyan}%(!.#.$) >%f '
# Syntax highlighting must see the final widget definitions.
for dotfiles_highlighter in ${dotfiles_highlight_files[@]}; do
  source "$dotfiles_highlighter"
done
unset dotfiles_highlighter dotfiles_highlight_files
