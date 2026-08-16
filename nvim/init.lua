-- Neovim entry point
-- 実際の設定は lua/config/ 以下に分割する

-- leader は lazy.nvim のロードより前に決める必要がある
-- (プラグインのキーマップが leader を前提に登録されるため)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
