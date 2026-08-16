-- 補完 (blink.cmp)
--
-- VSCodeの補完体験に寄せる。nvim組み込みのvim.lsp.completionは
-- ソースがLSPだけでファジーマッチも無いため使わない。

return {
  {
    'saghen/blink.cmp',
    -- versionを指定するとリリースに添付されたRust製fuzzy matcherの
    -- ビルド済みバイナリを取ってくる。cargoビルドを避けられる。
    version = '1.*',
    event = 'InsertEnter',
    dependencies = {
      -- 標準的なスニペット集。LSPが返さない言語でも最低限効かせる
      { 'rafamadriz/friendly-snippets' },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- super-tab: <Tab>で候補を確定し、スニペット展開中は次のプレースホルダへ。
        -- VSCodeのTab確定に一番近い。
        preset = 'super-tab',

        -- 以下3つはinsertモードのEmacsバインド (lua/config/keymaps.lua) と
        -- 衝突するので、blink側の割り当てを外して別のキーへ移す。
        -- (blinkのfallbackは補完メニューが出ていないときだけ既存マップに
        --  落ちるため、放置するとメニュー表示中にカーソル移動できなくなる)
        ['<C-b>'] = {},
        ['<C-f>'] = {},
        ['<C-e>'] = {},
        -- ドキュメントのスクロールとキャンセルの引っ越し先。
        -- <C-u> / <C-d> はプレフィックスキーではないので fallback でよい
        -- (メニュー非表示時は i_CTRL-U / i_CTRL-D がそのまま効く)
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        -- <C-g> は i_CTRL-G_u / i_CTRL-G_j 等のプレフィックスキーなので
        -- fallback で生キーを送るとnvimが次の入力を待って固まる (実測)。
        -- fallback_to_mappingsなら既存マップが無いとき何も送らないので固まらない。
        -- 代償として i_CTRL-G_* が使えなくなるが、Emacsバインド構成では
        -- <C-g> = キャンセル の方が自然なので受け入れる。
        ['<C-g>'] = { 'cancel', 'fallback_to_mappings' },
      },

      appearance = {
        -- Nerd Fontのアイコン幅を正しく計算させる
        nerd_font_variant = 'mono',
      },

      completion = {
        menu = {
          border = 'rounded',
          -- 候補が1つでLSPが確定済みのときも出す (何が起きたか分かるように)
          draw = {
            treesitter = { 'lsp' },
          },
        },
        documentation = {
          -- 選択した候補のドキュメントを自動で開く (VSCodeと同じ)
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = 'rounded' },
        },
        list = {
          selection = {
            -- 先頭候補を自動選択しない。
            -- super-tabの<Tab>がselect_and_acceptなので、preselectすると
            -- インデント目的の<Tab>が意図しない候補を挿入してしまう。
            preselect = false,
            -- 選択しただけでバッファに挿入しない (確定は<Tab>のみ)
            auto_insert = false,
          },
        },
        ghost_text = {
          -- インラインのプレビューは出さない (virtual_linesと視覚的に競合する)
          enabled = false,
        },
      },

      signature = {
        -- 関数の引数ヒント。0.12の i_<C-S> と役割が重なるが、
        -- 自動表示はblink側が優秀なので有効にする。
        enabled = true,
        window = { border = 'rounded' },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          -- VSCodeが [go] で editor.snippetSuggestions = "none" にしている
          -- のと揃える。goplsの候補にスニペットが混ざると邪魔になる。
          go = { 'lsp', 'path', 'buffer' },
        },
      },

      fuzzy = {
        -- Rust実装が取れなければLuaにフォールバックし警告を出す。
        -- プロキシ環境でリリースバイナリの取得が失敗しても起動は壊れない。
        implementation = 'prefer_rust_with_warning',
      },
    },
    opts_extend = { 'sources.default' },
  },
}
