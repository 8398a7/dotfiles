-- lint (nvim-lint)
--
-- LSPがカバーしないlinterを診断として出す。
--
-- go vet は移行しない。goplsが同じanalyzerを内蔵しており、
-- printf / copylocks / unreachable / assign を含めて go vet の指摘を
-- すべて出す上に staticcheck 由来のもの (SA5008など) も追加で出す (実測)。
-- go vet の起動は1.27秒かかるので、重複分を丸ごと削る。

return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        -- goplsが出さないのはスタイル系 (var-naming / exported など) だけなので
        -- reviveのみ足す
        go = { 'revive' },
        -- bashlsのshellcheck連携は after/lsp/bashls.lua で切ってあるので
        -- ここが唯一のshellcheck実行経路になる
        sh = { 'shellcheck' },
        bash = { 'shellcheck' },
        terraform = { 'tflint' },
      }

      -- reviveはパッケージ単位でしか動かない。
      -- ファイルパスを直接渡すとvendorディレクトリのあるリポジトリで
      -- 「import lookup disabled by -mod=vendor」で失敗する (実測)。
      -- nvim-lintは args の *各要素* だけを関数として評価する
      -- (lint.luaのeval_fn_or_id)。args自体やcwdに関数を入れると
      -- 「Invalid 'args': Cannot convert given Lua type」で落ちるため、
      -- バッファごとに変えたいときはlinter全体を関数にする
      -- (lookup_linterが呼び出してくれる)。
      local revive_base = lint.linters.revive
      lint.linters.revive = function()
        local dir = vim.fn.expand('%:p:h')
        local args = { '-formatter', 'json' }

        -- リポジトリの revive.toml があれば使う。
        -- (go.lintFlags の -config=${workspaceRoot}/revive.toml 相当)
        --
        -- vim.fs.rootはマーカを *リストの順に* 上方探索するので、
        -- revive.tomlを先頭に置けばネストしたgo.modより優先される。
        -- ネストした go.mod がある場合も、リポジトリ直下の revive.toml を
        -- 優先して見つけられるようにする。
        local root = vim.fs.root(0, { 'revive.toml', 'go.mod', '.git' })
        if root and vim.uv.fs_stat(root .. '/revive.toml') then
          table.insert(args, '-config=' .. root .. '/revive.toml')
        end

        -- カレントバッファのあるディレクトリだけを対象にする。
        -- ./... は大きなリポジトリで時間がかかるため使わない。
        --
        -- './' ではなく絶対パスを渡す。reviveは受け取ったパスの形式のまま
        -- Position.Start.Filename を返すので、'./' だと "common.go" のような
        -- 相対パスになる。nvim-lintのパーサはこれを expand('%:p') と
        -- 文字列比較するため、全ての指摘が捨てられて診断が0件になる (実測)。
        -- 絶対パスでも速度は同じ (どちらも0.006秒)。
        table.insert(args, dir .. '/')

        return vim.tbl_extend('force', revive_base, {
          name = 'revive',
          args = args,
          append_fname = false,
          cwd = dir,
          -- revive.toml の設定によっては指摘があると非ゼロで終了しても、
          -- JSON は stdout に正しく出るため終了コードは見ない。
          ignore_exitcode = true,
        })
      end

      -- linterのバイナリが無いリポジトリでは黙って飛ばす。
      -- reviveやtflintはリポジトリごとのmise.tomlで入るので、
      -- プロジェクトによってはインストールされていない。
      -- nvim-lintにcondition相当の仕組みは無く、そのまま呼ぶと保存ごとに
      -- 「Error running revive: ENOENT」が出る (実測) ので、filterで落とす。
      local function try_lint()
        lint.try_lint(nil, {
          filter = function(linter)
            return vim.fn.executable(linter.cmd) == 1
          end,
        })
      end

      -- 保存後・読み込み後・insertを抜けたときにlintする。
      -- reviveは0.006秒なのでInsertLeaveでも走らせて問題ない (実測)。
      local group = vim.api.nvim_create_augroup('MyLint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group = group,
        callback = try_lint,
      })

      vim.api.nvim_create_user_command(
        'Lint',
        try_lint,
        { desc = 'linterを手動で実行する' }
      )
    end,
  },
}
