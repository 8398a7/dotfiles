-- Git 連携
--
-- 2段構成にする。
--   gitsigns.nvim  ... 行単位の差分・hunk操作・blame。日常操作の主力
--   diffview.nvim  ... 差分とファイル履歴をまとめて見る
--
-- コミット・ブランチ操作そのものはターミナル側に残す。
-- zsh側に fzf_git / fzf_git_show / git_pull_and_prune と
-- glg / gla / gps のエイリアスが揃っているので、nvimに持ち込まない。
-- コミット一覧・ブランチ一覧の閲覧だけは lua/plugins/finder.lua の
-- fzf-lua (<leader>fc / <leader>fB) 側にある。
--
-- fugitiveは入れない。旧 vim/_config/100-lightline.vim が MyFugitive で
-- ブランチ名を出すために依存していたが、lualineはgitsignsのbranch情報を
-- 使えるので不要になる。

return {
  {
    'lewis6991/gitsigns.nvim',
    -- gitリポジトリ外でも黙って何もしないだけなので、
    -- ファイルを開いた時点でロードしてよい
    event = { 'BufReadPre', 'BufNewFile' },
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    opts = {
      -- 行末のblame表示は情報量が多くて邪魔になりやすいので既定はオフ。
      -- <leader>gb で必要なときだけトグルする
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = 'eol',
      },

      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- hunk間の移動。diffモード中は素の ]c / [c に任せる
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, '次の変更へ')

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, '前の変更へ')

        -- hunk操作。<leader>g で始める
        map('n', '<leader>gs', gs.stage_hunk, 'hunkをステージする')
        map('n', '<leader>gr', gs.reset_hunk, 'hunkを元に戻す')
        local function visual_range()
          local first, last = vim.fn.line('v'), vim.fn.line('.')
          return { math.min(first, last), math.max(first, last) }
        end
        map('x', '<leader>gs', function()
          gs.stage_hunk(visual_range())
        end, '選択範囲をステージする')
        map('x', '<leader>gr', function()
          gs.reset_hunk(visual_range())
        end, '選択範囲を元に戻す')
        map('n', '<leader>gS', gs.stage_buffer, 'バッファ全体をステージする')
        map('n', '<leader>gR', gs.reset_buffer, 'バッファ全体を元に戻す')
        map('n', '<leader>gp', gs.preview_hunk, 'hunkの差分をプレビューする')
        map('n', '<leader>gd', gs.diffthis, 'インデックスとの差分を開く')
        map(
          'n',
          '<leader>gb',
          gs.toggle_current_line_blame,
          '行末のblame表示を切り替える'
        )
        map('n', '<leader>gB', function()
          gs.blame_line({ full = true })
        end, 'この行のblameを表示する')

        -- テキストオブジェクト。dih で hunk を消す、vih で選ぶ
        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'hunkを選択する')
      end,
    },
  },

  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
    keys = {
      { '<leader>gv', '<Cmd>DiffviewOpen<CR>', desc = '変更全体の差分を開く' },
      {
        '<leader>gh',
        '<Cmd>DiffviewFileHistory %<CR>',
        desc = 'このファイルの履歴を開く',
      },
      {
        '<leader>gh',
        "<Cmd>'<,'>DiffviewFileHistory<CR>",
        mode = 'x',
        desc = '選択範囲の履歴を開く',
      },
    },
    opts = {
      -- 差分は左右に並べる
      view = {
        default = { layout = 'diff2_horizontal' },
      },
    },
  },
}
