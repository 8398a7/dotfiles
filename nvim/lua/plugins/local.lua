-- このリポジトリに同梱する自作プラグイン
--
-- lua/local/<name>/ に置き、lazy.nvim の dir 指定でローカルディレクトリとして
-- 読み込む。

return {
  {
    'local.herdr',
    dir = vim.fn.stdpath('config') .. '/lua/local/herdr',
    name = 'local.herdr',
    -- キーマップを張るだけなので遅延させてもよいが、<C-h/j/k/l> は
    -- 起動直後から効いてほしいので素直に読み込む
    lazy = false,
    config = function()
      require('local.herdr').setup()
    end,
  },
}
