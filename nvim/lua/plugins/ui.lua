-- 見た目 (colorscheme / statusline / ファイルツリー)

return {
  -- colorscheme {{{
  -- 旧 vim/colors/theme.vim の個別 hi 12行は廃棄する。
  -- treesitter・LSP・診断のハイライトグループに対応した配色が必要で、
  -- 手書きのhiではU4のパーサが出すグループを網羅できない。
  --
  -- catppuccinを選ぶ理由は herdr/config.toml が [theme] name = "catppuccin"、
  -- accent = "#a6e3a1" (mochaのgreen) を指定していること。
  -- ペインの枠とnvimの色が揃う。
  -- (VSCodeは One Monokai、tmux-powerlineとzshのsetupsolarizedは
  --  solarized系だったが、tmuxはherdrへ移行するので合わせる相手はherdr)
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
          -- 旧 vim/_config/101-nerdtree.vim は
          -- hi Directory guifg=#FF0000 でディレクトリを赤くしていた。
          -- 赤はcatppuccinでは削除・エラーの色なので踏襲しない。
          -- 代わりにaccentと同じgreenで目立たせる
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
  -- 旧 vim/_config/100-lightline.vim (62行) の置き換え。
  -- 旧設定は MyModified / MyReadonly / MyFilename などを手書きし、
  -- しかも colorscheme: 'solarized' が実際のcolorschemeと一致していなかった。
  --
  -- 旧設定が左に出していたのは mode / paste / fugitive(branch) / filename。
  -- これを引き継ぎ、右に診断件数・LSP名・filetype・エンコーディングを足す。
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
            -- 診断件数。U5のLSPとU7のnvim-lintの両方がここに出る
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
      -- 旧 vim/_config/101-nerdtree.vim の nnoremap <C-f> :NERDTreeToggle<CR>
      { '<C-f>', '<Cmd>Neotree toggle<CR>', desc = 'ファイルツリーを開閉する' },
      {
        '<leader>fe',
        '<Cmd>Neotree reveal<CR>',
        desc = 'ツリーで現在のファイルを表示する',
      },
    },
    opts = {
      -- 旧設定の
      --   autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") ...) | q | endif
      -- (ツリーだけが残ったらnvimを閉じる) と同じ意図。
      -- neo-treeは自前のオプションで同じことをする
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
