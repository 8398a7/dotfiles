#!/bin/bash -xeu

# for git
rm -rf $HOME/.config/git
ln -s $HOME/dotfiles/git $HOME/.config/git

# for tmux
rm $HOME/.tmux $HOME/.tmux.conf
ln -s $HOME/dotfiles/tmux $HOME/.tmux
ln -s $HOME/dotfiles/tmux/.tmux.conf $HOME/.tmux.conf

# for vim
rm $HOME/.vim $HOME/.vimrc
ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/dotfiles/vim/.vimrc $HOME/.vimrc

# for zsh
rm $HOME/.zsh $HOME/.zshrc
ln -s $HOME/dotfiles/zsh $HOME/.zsh
ln -s $HOME/dotfiles/zsh/.zshrc $HOME/.zshrc
