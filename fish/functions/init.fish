function init --on-event init_dircolors
  eval (command dircolors -c "$HOME/dotfiles/fish/.dir_colors")
end
