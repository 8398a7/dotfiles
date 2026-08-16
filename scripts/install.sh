#!/bin/bash -xeu

# for git
rm -rf $HOME/.config/git
mkdir -p $HOME/.config
ln -s $HOME/dotfiles/git $HOME/.config/git
rm -f $HOME/.gitconfig
ln -s $HOME/dotfiles/git/.gitconfig $HOME/.gitconfig

# for herdr
# ログやソケットが同じディレクトリに生成されるのでディレクトリごとリンクはできない
rm -f $HOME/.config/herdr/config.toml $HOME/.config/herdr/bin
mkdir -p $HOME/.config/herdr
ln -s $HOME/dotfiles/herdr/config.toml $HOME/.config/herdr/config.toml
ln -s $HOME/dotfiles/herdr/bin $HOME/.config/herdr/bin

# for nvim
# 生成物は~/.local/share/nvimと~/.cache/nvimに出るのでディレクトリごとリンクできる
rm -rf $HOME/.config/nvim
ln -s $HOME/dotfiles/nvim $HOME/.config/nvim

# for tmux
rm -f $HOME/.tmux $HOME/.tmux.conf
ln -s $HOME/dotfiles/tmux $HOME/.tmux
ln -s $HOME/dotfiles/tmux/.tmux.conf $HOME/.tmux.conf

# for vim
rm -f $HOME/.vim $HOME/.vimrc
ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/dotfiles/vim/.vimrc $HOME/.vimrc

# for zsh
rm -f $HOME/.zsh $HOME/.zshrc
ln -s $HOME/dotfiles/zsh $HOME/.zsh
ln -s $HOME/dotfiles/zsh/.zshrc $HOME/.zshrc
rm -rf $HOME/.config/sheldon
mkdir -p $HOME/.config/sheldon
ln -s $HOME/dotfiles/zsh/plugins.toml $HOME/.config/sheldon/plugins.toml

case $OSTYPE in
  # darwin {{{
  darwin*)
    # for git
    # brewはmacOSのみ前提(zsh/.zshrcと同じ扱い)
    sudo rm -f /usr/local/bin/diff-highlight
    sudo ln -s $(brew --prefix git)/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight

    # for vscode
    rm -f $HOME/Library/Application\ Support/Code/User/settings.json
    ln -s $HOME/dotfiles/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
    ;;
  # }}}
  linux*)
    ;;
esac
