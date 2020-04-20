#!/bin/bash -xeu

# for git
rm -rf $HOME/.config/git
mkdir $HOME/.config || true
ln -s $HOME/dotfiles/git $HOME/.config/git
rm -f $HOME/.gitconfig
ln -s $HOME/dotfiles/git/.gitconfig $HOME/.gitconfig
rm -f /usr/local/bin/diff-highlight
ln -s /usr/local/share/git-core/contrib/diff-highlight/diff-highlight /usr/local/bin

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
