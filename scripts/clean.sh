#!/bin/bash -xeu

rm $HOME/.vim $HOME/.vimrc $HOME/.zsh $HOME/.zshrc $HOME/.tmux $HOME/.tmux.conf $HOME/.config/git $HOME/.config/sheldon
exec -l $SHELL
