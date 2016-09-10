(require 'cask "/usr/local/Cellar/cask/0.7.2/cask.el")
(cask-initialize)
(require 'pallet)
(require 'init-loader)
(pallet-mode t)

(setq init-loader-show-log-after-init nil)
(init-loader-load "~/.emacs.d/inits")

(show-paren-mode t)
(display-time)
