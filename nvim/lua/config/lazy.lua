-- lazy.nvim のブートストラップとセットアップ
-- https://lazy.folke.io/installation

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  local repo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    repo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    -- プロキシ環境では git の http.proxy 設定が必要
    -- ($XDG_CONFIG_HOME/git/.gitconfig.local を参照)
    vim.api.nvim_echo({
      { 'lazy.nvim の clone に失敗しました:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nプロキシ設定 (git config --get http.proxy) を確認してください', nil },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    -- lua/plugins/ 以下の *.lua を自動で読み込む
    { import = 'plugins' },
  },
  -- プラグイン更新の通知は不要 (lockfile で明示的に管理する)
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- 使わない標準プラグインを無効化する
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
