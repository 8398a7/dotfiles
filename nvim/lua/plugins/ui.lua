-- 見た目 (colorscheme / statusline / ファイルツリー)

return {
  -- colorscheme {{{
  -- treesitter・LSP・診断のハイライトグループに対応した配色を使う。
  --
  -- catppuccinを選ぶ理由は herdr/config.toml が [theme] name = "catppuccin"、
  -- accent = "#a6e3a1" (mochaのgreen) を指定していること。
  -- ペインの枠とnvimの色が揃う。
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    -- colorschemeは他のプラグインより先に読む
    lazy = false,
    priority = 1000,
    opts = {
      flavour = 'mocha',
      -- 背景を端末に任せる。herdr側のpanel_bgと食い違わないようにする
      transparent_background = true,
      integrations = {
        -- catppuccinは auto_integrations = true で入っているプラグインを
        -- 自動検出するが、コンパイル済みキャッシュのハッシュは
        -- ユーザ設定だけから作られていて検出結果を含まない
        -- (lua/catppuccin/init.lua)。つまりプラグインを後から足しても
        -- キャッシュが再生成されず、そのプラグインのハイライトが
        -- 定義されないままになる (実測: nvim-dapを足した直後
        -- DapBreakpoint が undefined、:CatppuccinCompile で解決した)。
        --
        -- ここに書いておけば設定のハッシュが変わるので確実に反映される。
        -- 自動検出に任せず、使うものは明示する。
        blink_cmp = true,
        fzf = true,
        neotree = true,
        diffview = true,
        dap = true,
        dap_ui = true,
        lsp_trouble = false,
      },
      custom_highlights = function(colors)
        return {
          -- ディレクトリはaccentと同じgreenで目立たせる
          Directory = { fg = colors.green, bold = true },
        }
      end,
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  -- }}}

  -- statusline {{{
  --
  -- Show editing mode, filename, Git status, diagnostics and LSP information.
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = function()
      return {
        options = {
          -- catppuccinが提供するlualineテーマの名前は 'catppuccin' ではなく
          -- 'catppuccin-nvim'。'catppuccin' だと
          -- 「Theme `catppuccin` not found, falling back to `auto`」で
          -- 黙ってautoに落ちる (実測: :LualineNotices)。
          -- flavourは中で自動判別されるので mocha/latte を書き分けなくてよい。
          theme = 'catppuccin-nvim',
          -- 旧設定は ⮀ / ⮁ (Powerlineフォント依存) を使っていた。
          -- フォントは Ricty for Powerline なので出せる
          -- (vscode/settings.json の terminal.integrated.fontFamily)。
          -- ただしlualineの既定 (nerd fontの / ) の方が字形が素直なので
          -- そちらに任せる
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
          -- statuslineは1本だけ出す (winbarやtablineは使わない)
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          -- gitsignsが無いリポジトリ外では自動的に空になる
          lualine_b = { 'branch', 'diff' },
          lualine_c = {
            -- 旧 MyFilename は modified / readonly を記号で足していた。
            -- lualineの filename が同じことをやる
            { 'filename', path = 1, symbols = { modified = '[+]', readonly = '[RO]' } },
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
            },
            -- 動いているLSPの名前
            {
              function()
                local names = {}
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  table.insert(names, client.name)
                end
                if #names == 0 then
                  return ''
                end
                return table.concat(names, ',')
              end,
              icon = 'LSP:',
            },
            'filetype',
          },
          lualine_y = {
            -- 旧 MyFileencoding / MyFileformat 相当。
            -- どちらも普段はutf-8とunixなので、違うときだけ出す
            {
              'encoding',
              cond = function()
                return vim.bo.fileencoding ~= '' and vim.bo.fileencoding ~= 'utf-8'
              end,
            },
            {
              'fileformat',
              cond = function()
                return vim.bo.fileformat ~= 'unix'
              end,
            },
          },
          lualine_z = { 'location' },
        },
      }
    end,
  },
  -- }}}

  -- ファイルツリー {{{
  -- 旧 NERDTree の代替を2つ入れて役割を分ける。
  --   oil.nvim   ... ディレクトリをバッファとして開いて編集する。主力
  --   neo-tree   ... 従来型のサイドバー。<C-f> でトグルする (旧NERDTreeの習慣)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- oilは vim.ui でディレクトリを開く経路を奪うので遅延させない。
    -- (nvim . のようにディレクトリを引数に起動したときに効かせるため)
    lazy = false,
    keys = {
      { '-', '<Cmd>Oil<CR>', desc = '親ディレクトリを開く' },
    },
    opts = {
      -- netrwを置き換える
      default_file_explorer = true,
      view_options = {
        -- ドットファイルも出す。設定ファイルを触ることが多い
        show_hidden = true,
      },
      -- ファイルの作成・削除・リネームをバッファの編集として扱うので、
      -- 保存時に確認を出す
      prompt_save_on_select_new_entry = true,
    },
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<C-f>', '<Cmd>Neotree toggle<CR>', desc = 'ファイルツリーを開閉する' },
      {
        '<leader>fe',
        '<Cmd>Neotree reveal<CR>',
        desc = 'ツリーで現在のファイルを表示する',
      },
    },
    opts = {
      -- Close the editor when the tree is the last window.
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          -- ドットファイルは薄く出す (完全に隠さない)。
          -- oil側と挙動を揃える
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          -- vendorはfzf-luaの検索から外しているのと同じ理由で畳んでおく
          -- (nvim/rgignore を参照)
          never_show = { '.git', 'node_modules', 'vendor' },
        },
        -- ファイルを開くとツリー側のカーソルも追従する
        follow_current_file = { enabled = true },
        -- ディレクトリに入ったときcwdを変えない。
        -- fzf-luaの検索対象がツリー操作でずれると混乱するため
        hijack_netrw_behavior = 'disabled',
      },
      window = {
        width = 34,
      },
    },
  },
  -- }}}
}
