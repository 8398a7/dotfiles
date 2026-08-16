-- ファイル検索・grep (fzf-lua)
--
-- zsh側がfzfベース (FZF_DEFAULT_OPTS="--extended --cycle --reverse --exact") なので
-- telescopeではなくfzf-luaを使い、検索の操作感を揃える。
-- 旧 zsh/functions/fzf_tree_vim.zsh (tree + fzf でファイルを選んでvimで開く) の
-- nvim内での置き換え。zsh側の関数はそのまま残す。
--
-- fdが入っていないのでfzf-luaはrgにフォールバックする
-- (providers/files.luaの fdfind → fd → rg → find の順、実測)。

-- 検索から外すディレクトリの一覧。rgの --ignore-file に渡す。
-- ファイル検索とgrepの両方で使う。
-- なぜグロブ (-g '!vendor') ではないかは nvim/rgignore の先頭に書いた。
local ignore_file = vim.fn.stdpath('config') .. '/rgignore'

return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = {
      -- 旧 <C-b> は tabnew だった。nvimはバッファ中心の運用にするので
      -- バッファ一覧に変える。タブが必要なときは :tabnew / gt / gT。
      -- (挿入モードの <C-b> = <Left> は別モードなので共存する)
      { '<C-b>', '<Cmd>FzfLua buffers<CR>', desc = 'バッファ一覧' },

      { '<leader>ff', '<Cmd>FzfLua files<CR>', desc = 'ファイル検索' },
      { '<leader>fg', '<Cmd>FzfLua live_grep<CR>', desc = 'grep検索' },
      { '<leader>fb', '<Cmd>FzfLua buffers<CR>', desc = 'バッファ一覧' },
      { '<leader>fh', '<Cmd>FzfLua oldfiles<CR>', desc = '最近開いたファイル' },
      { '<leader>fl', '<Cmd>FzfLua blines<CR>', desc = 'このバッファ内を検索' },
      { '<leader>fr', '<Cmd>FzfLua resume<CR>', desc = '直前の検索を再開' },
      { '<leader>fw', '<Cmd>FzfLua grep_cword<CR>', desc = 'カーソル下の単語をgrep' },
      { '<leader>fw', '<Cmd>FzfLua grep_visual<CR>', mode = 'x', desc = '選択範囲をgrep' },

      -- git。gitsigns側 (lua/plugins/git.lua) と役割を分けていて、
      -- こちらは「一覧から選ぶ」もの
      { '<leader>fc', '<Cmd>FzfLua git_commits<CR>', desc = 'コミット履歴' },
      {
        '<leader>fC',
        '<Cmd>FzfLua git_bcommits<CR>',
        desc = 'このファイルのコミット履歴',
      },
      { '<leader>fs', '<Cmd>FzfLua git_status<CR>', desc = 'gitで変更のあるファイル' },
      { '<leader>fB', '<Cmd>FzfLua git_branches<CR>', desc = 'ブランチ一覧' },

      -- LSP。gd / gr / K などの単発ジャンプは after/lsp 側にある
      {
        '<leader>fd',
        '<Cmd>FzfLua diagnostics_document<CR>',
        desc = 'このファイルの診断',
      },
      {
        '<leader>fD',
        '<Cmd>FzfLua diagnostics_workspace<CR>',
        desc = 'ワークスペースの診断',
      },
      {
        '<leader>fo',
        '<Cmd>FzfLua lsp_document_symbols<CR>',
        desc = 'このファイルのシンボル',
      },
      {
        '<leader>fO',
        '<Cmd>FzfLua lsp_live_workspace_symbols<CR>',
        desc = 'ワークスペースのシンボル',
      },
      { '<leader>fR', '<Cmd>FzfLua lsp_references<CR>', desc = '参照一覧' },
      { '<leader>fi', '<Cmd>FzfLua lsp_implementations<CR>', desc = '実装一覧' },

      { '<leader>fk', '<Cmd>FzfLua keymaps<CR>', desc = 'キーマップ一覧' },
      { '<leader>f?', '<Cmd>FzfLua builtin<CR>', desc = 'fzf-luaの機能一覧' },
    },
    opts = {
      -- プロファイル。'ivy' は画面下部に横長で出るので
      -- zsh側のfzf (--reverse) に近い見た目になる
      'ivy',

      fzf_opts = {
        -- zsh/.zshrc の FZF_DEFAULT_OPTS="--extended --cycle --reverse --exact" を
        -- 持ち込む。fzf-luaはFZF_DEFAULT_OPTSを読まず自前のdefaultsを使うので明示する。
        -- --reverse と --extended は fzf-lua の既定と ivy プロファイルで既に入っている。
        --
        -- --exact はあいまい検索を切って部分一致にするオプション。
        -- あいまい検索したいときはクエリの先頭に ' を付けるとfzfが反転してくれる。
        ['--cycle'] = true,
        ['--exact'] = true,
      },

      files = {
        -- 既定は [[--color=never --files -g "!.git" -g "!.jj"]]。
        -- .jjは使っていないので落とす。
        --
        -- .git はグロブのまま残す。--ignore-file 側に書くと alt-i で
        -- 戻ってきてしまうため。
        --
        -- --hidden はfzf-luaが toggle_hidden_flag として付け外しするので
        -- ここには書かない (既定で hidden=true なので初回から付く)。
        rg_opts = [[--color=never --files -g "!.git" --ignore-file ]]
          .. vim.fn.shellescape(ignore_file),
        cwd_prompt = true,
      },

      grep = {
        -- 既定の末尾 -e は必須 (この後にクエリが連結される)
        rg_opts = '--column --line-number --no-heading --color=always --smart-case '
          .. [[--max-columns=4096 -g "!.git" --ignore-file ]]
          .. vim.fn.shellescape(ignore_file)
          .. ' -e',
      },
    },

    config = function(_, opts)
      local fzf = require('fzf-lua')

      -- alt-i (toggle_ignore) が付ける --no-ignore だけでは
      -- --ignore-file の指定は解除されない (実測: vendorが0件のまま)。
      -- --no-ignore-files まで付けて初めてvendorが戻る。
      -- fzf-luaはこのフラグ文字列をコマンドから足し引きするだけなので、
      -- 両方をまとめて1つのフラグとして渡せばトグルとして成立する。
      local toggle_ignore_flag = '--no-ignore --no-ignore-files'
      opts.files.toggle_ignore_flag = toggle_ignore_flag
      opts.grep.toggle_ignore_flag = toggle_ignore_flag

      fzf.setup(opts)

      -- vim.ui.select をfzfに差し替える。
      -- LSPのコードアクションやリネーム候補の選択がfzfで出るようになる
      fzf.register_ui_select()
    end,
  },
}
