#!/bin/bash -xeu

rm -f $HOME/Gemfile $HOME/.gemrc
ln -s $HOME/dotfiles/ruby/Gemfile $HOME/Gemfile
ln -s $HOME/dotfiles/ruby/.gemrc $HOME/.gemrc
cd $HOME; bundle install -j6
rbenv rehash
