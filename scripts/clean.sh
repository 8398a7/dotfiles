#!/bin/bash -xeu

# install.shが張ったリンクを消す
# 2回連続で実行しても止まらないようにrm -fで揃える
# .config/sheldonだけはinstall.shがmkdirした実ディレクトリなのでrm -rfが必要
rm -f $HOME/.gitconfig
rm -rf $HOME/.config/git
rm -f $HOME/.config/herdr/config.toml $HOME/.config/herdr/bin
rm -rf $HOME/.config/nvim
rm -rf $HOME/.config/sheldon
rm -f $HOME/.tmux $HOME/.tmux.conf
rm -f $HOME/.vim $HOME/.vimrc
rm -f $HOME/.zsh $HOME/.zshrc

exec -l $SHELL
