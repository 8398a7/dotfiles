-- LSPサーバ・フォーマッタ・リンタの入手経路 (Mason) とLSPの有効化
--
-- サーバの設定はnvim-lspconfigのlsp/<name>.luaをベースにする。
-- 上書きしたい差分だけを nvim/after/lsp/<name>.lua に置く。
--
-- lsp/*.luaはruntimepath上の同名ファイルを順に tbl_deep_extend('force') で
-- 畳み込む (runtime/lua/vim/lsp.lua の vim.lsp.config.__index) ため、
-- 後に読まれる方が勝つ。~/.config/nvim/lsp はlazyのプラグインより先に
-- 来るのでlspconfigに負ける。afterディレクトリなら最後に読まれる。

-- 有効化するLSPサーバ。名前はlspconfigのlsp/<name>.luaに合わせる。
local servers = {
  'bashls',
  'gopls',
  'jsonls',
  'lua_ls',
  'marksman',
  'ruby_lsp',
  'taplo',
  'terraformls',
  'vtsls',
  'yamlls',
}

-- Masonで入れるツール。
--
-- ここに入れないもの (プロジェクト側の固定を優先する):
--   goimports / revive / staticcheck  ... プロジェクトのmise.tomlで固定
-- これらはPATHのappend設定によりMason版を入れても隠れるが、
-- 二重管理を避けるため最初から入れない。
local tools = {
  -- LSP
  'bash-language-server',
  'gopls',
  'json-lsp',
  'lua-language-server',
  'marksman',
  'ruby-lsp',
  'taplo',
  'terraform-ls',
  'vtsls',
  'yaml-language-server',
  -- フォーマッタ・リンタ
  'buf',
  'shellcheck',
  'shfmt',
  'stylua',
  'tflint',
  -- その他
  'delve', -- Goデバッガ
  'tree-sitter-cli', -- パーサのビルド
}

return {
  {
    'mason-org/mason.nvim',
    -- lazyにするとMasonのbinがPATHに入らず、tree-sitter-cliやフォーマッタが
    -- 「無い」と判定される。ロードは1ms程度なので起動時に読む。
    lazy = false,
    priority = 100,
    build = ':MasonUpdate',
    opts = {
      -- Masonが入れたツールはPATHの末尾に足す。
      -- プロジェクト側で固定されたバージョン (mise shims / node_modules) を
      -- 優先させるため prepend にはしない。
      PATH = 'append',
      ui = {
        border = 'rounded',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)

      -- 新規マシンでのセットアップ用。
      -- 起動時に自動で走らせるとプロキシ環境で起動が遅くなり
      -- ミラー障害時に毎回失敗するので、明示的に叩く運用にする。
      vim.api.nvim_create_user_command('MasonInstallTools', function()
        local registry = require('mason-registry')
        registry.refresh(function()
          local missing = vim.tbl_filter(function(t)
            return not registry.is_installed(t)
          end, tools)
          if #missing == 0 then
            vim.notify('Masonのツールはすべてインストール済みです')
            return
          end
          vim.notify('インストールします: ' .. table.concat(missing, ', '))
          vim.cmd('MasonInstall ' .. table.concat(missing, ' '))
        end)
      end, { desc = '宣言済みのMasonツールをまとめてインストールする' })
    end,
  },

  -- nvim設定を書くときのLua型情報。lua_lsに動的にライブラリを渡す。
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- vim.uv の型情報
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- LSPの有効化と診断表示。プラグインではなく設定のみ。
  {
    'neovim/nvim-lspconfig',
    -- setup()は呼ばない。root_markersやcmdのデフォルトを参照するためだけに入れる。
    lazy = false,
    config = function()
      -- capabilitiesはinitializeで一度だけ送られるので、サーバを起動する前に
      -- 決めておく必要がある。blink.cmpはInsertEnterまでロードされないため、
      -- ここではモジュールを直接requireしてsetup()より先に読む。
      -- (get_lsp_capabilitiesはsetup()に依存しない)
      local ok, blink = pcall(require, 'blink.cmp')
      if ok then
        vim.lsp.config('*', {
          -- blinkはsnippetSupportやresolveSupportをnvimのデフォルトより
          -- 広く申告する。'*' は lsp/<name>.lua より低い優先度で全サーバに効く。
          capabilities = blink.get_lsp_capabilities(nil, true),
        })
      end

      vim.lsp.enable(servers)

      vim.diagnostic.config({
        -- デフォルトはsignsとunderlineだけでメッセージ本文が画面に出ない。
        -- 行末に出すvirtual_textは長いメッセージが切れるため、
        -- カーソル行だけコード下に複数行で出すvirtual_linesを使う。
        virtual_text = false,
        virtual_lines = { current_line = true },
        underline = true,
        severity_sort = true,
        signs = {
          -- :sign-define による設定は0.12の診断側から参照されない
          -- (エラーにはならず黙って効かない) ため、ここで設定する。
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        float = {
          border = 'rounded',
          source = true,
        },
      })

      -- 0.11以降のLSPデフォルトキーマップ (grn / gra / grr / gri / grt /
      -- grx / gO / i_<C-S>) はそのまま使う。デフォルトに無い2つだけ足す。
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = '定義へ移動' })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'ホバー情報を表示' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = '診断を表示' })

      -- lspconfigの:LspRestartはsetup()前提でlspconfig.configsを引くため、
      -- setup()を呼ばないこの構成ではサーバを止めたまま再起動しない (実測)。
      -- vim.lsp.enableのfalse/trueで停止と再アタッチが完結するので置き換える。
      vim.api.nvim_create_user_command('LspRestart', function(info)
        local names = #info.fargs > 0 and info.fargs
          or vim.tbl_map(function(c)
            return c.name
          end, vim.lsp.get_clients({ bufnr = 0 }))
        if #names == 0 then
          vim.notify('再起動するLSPクライアントがありません', vim.log.levels.WARN)
          return
        end
        vim.lsp.enable(names, false)
        vim.lsp.enable(names)
        vim.notify('再起動しました: ' .. table.concat(names, ', '))
      end, {
        desc = 'LSPサーバを再起動する',
        nargs = '*',
        complete = function()
          return servers
        end,
      })
    end,
  },
}
