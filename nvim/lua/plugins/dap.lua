-- デバッグ (nvim-dap)
--
-- VSCode の golang.go デバッガの代替。delve は Mason で入れている
-- (lua/plugins/lsp.lua の tools に 'delve' がある)。
-- Masonのbinは PATH = 'append' で追加されるので、dlvはPATH経由で見つかる。
--
-- 最小構成として「現在のパッケージをデバッグ起動」と「テストをデバッグ実行」の
-- 2つだけを用意する。どちらも nvim-dap-go が提供する。
-- コンテナ内delveへのremote attachは、実際に必要になってから
-- configurations に足す。ポート番号のような環境依存の値を
-- dotfilesに埋めたくないので、その時は .nvim.lua 側に置くか検討する。

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- UI (スコープ・スタックトレース・ブレークポイント一覧)
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        opts = {},
        config = function(_, opts)
          local dap, dapui = require('dap'), require('dapui')
          dapui.setup(opts)

          -- セッションの開始・終了に合わせてUIを開閉する。
          -- VSCodeがデバッグ開始でパネルを出すのと同じ感覚にする
          dap.listeners.after.event_initialized['dapui'] = function()
            dapui.open()
          end
          -- terminated / exited は自動で閉じない。
          -- 停止した瞬間の変数やスタックを見返したいことが多いので、
          -- 閉じるのは <leader>du に任せる
        end,
      },

      -- Go用の設定を自動生成する。
      -- debug / test / attach の configurations と、
      -- カーソル位置のテスト関数だけをデバッグする機能が付いてくる
      {
        'leoluz/nvim-dap-go',
        opts = {},
      },
    },

    -- keysの右辺は必ず関数の中で require する。
    -- keys = function() の外側で require('dap') すると
    -- 仕様の評価時 (= nvim起動時) にdapが読まれてしまい、遅延ロードが効かない
    -- (実測: 起動直後に nvim-dap / nvim-dap-ui が loaded になった)。
    keys = {
      -- VSCodeと同じFキー。移行中に指が覚えていることを優先する。
      -- ただしVSCodeの Shift+F5 (停止) は入れない。TERMが
      -- xterm-256colorなので端末がShift+Fキーを送らず、押しても効かない
      -- キーが <leader>fk の一覧に並ぶだけになる。停止は <leader>dx。
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'デバッグ開始 / 続行',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'ステップオーバー',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'ステップイン',
      },
      {
        '<F12>',
        function()
          require('dap').step_out()
        end,
        desc = 'ステップアウト',
      },
      -- Fキーが端末で潰れることがあるので <leader>d 側にも同じものを置く。
      -- step系の割り当ては LazyVim と揃えている (do = out, dO = over)
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'デバッグ開始 / 続行',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'ステップイン',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'ステップアウト',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_over()
        end,
        desc = 'ステップオーバー',
      },
      {
        '<leader>dx',
        function()
          require('dap').terminate()
        end,
        desc = 'デバッグ終了',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = '直前の構成でもう一度デバッグ',
      },

      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'ブレークポイントを置く / 外す',
      },
      {
        '<leader>dB',
        function()
          vim.ui.input({ prompt = '止まる条件: ' }, function(cond)
            if cond and cond ~= '' then
              require('dap').set_breakpoint(cond)
            end
          end)
        end,
        desc = '条件付きブレークポイントを置く',
      },
      {
        '<leader>dL',
        function()
          vim.ui.input({ prompt = 'ログに出す式: ' }, function(msg)
            if msg and msg ~= '' then
              require('dap').set_breakpoint(nil, nil, msg)
            end
          end)
        end,
        desc = 'ログポイントを置く',
      },

      -- 変数の中身を見る。dap-uiのフロートで出す
      {
        '<leader>de',
        function()
          require('dapui').eval()
        end,
        mode = { 'n', 'x' },
        desc = 'カーソル下 / 選択範囲の値を見る',
      },
      {
        '<leader>du',
        function()
          require('dapui').toggle()
        end,
        desc = 'デバッグUIを開閉する',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'デバッグREPLを開閉する',
      },

      -- Go固有。nvim-dap-goが提供する
      {
        '<leader>dt',
        function()
          require('dap-go').debug_test()
        end,
        desc = 'カーソル位置のテストをデバッグする',
      },
      {
        '<leader>dT',
        function()
          require('dap-go').debug_last_test()
        end,
        desc = '直前のテストをもう一度デバッグする',
      },
    },

    config = function()
      local dap = require('dap')

      -- delveが入っていないときの案内。
      --
      -- 素の状態だと
      --   Executable `dlv` not found, fix the adapter definition for `go`
      -- とだけ出る。「adapterの定義を直せ」は原因の切り分けとしては正しくないので
      -- (定義ではなくツールが無いだけ)、Masonで入れる導線を先に出す。
      --
      -- dependenciesのnvim-dap-goが先にロードされて adapters.go を
      -- 入れているので、ここで包める (実測: この時点で adapters.go は非nil)。
      local dap_go_adapter = dap.adapters.go
      dap.adapters.go = function(callback, config)
        if vim.fn.executable('dlv') == 0 then
          vim.notify(
            'delve (dlv) が見つかりません。:MasonInstallTools か '
              .. ':Mason で delve を入れてください',
            vim.log.levels.ERROR
          )
          return
        end
        return dap_go_adapter(callback, config)
      end

      -- ビルドが通らないコードでデバッグ起動したときの受け皿。
      --
      -- delveはビルドエラーの本文を output イベント (stderr) で送ってくるが、
      -- launchのエラーレスポンス側には showUser = false で
      -- 「Failed to launch: Build error: Check the debug console for details.」
      -- しか入れてこない (実測)。nvim-dapは showUser を尊重するので
      -- 画面には「Error on launch: Failed to launch」だけが出て、
      -- どこが間違っているのか分からない。
      --
      -- 本文はREPLバッファには入っているので、失敗したときだけREPLを開く。
      -- セッションはこの時点でcloseされているがバッファは残る。
      dap.listeners.after.launch['build-error'] = function(_, err)
        if err then
          dap.repl.open()
        end
      end

      -- 記号。テキストのハイライトグループはcatppuccinが定義している
      -- (auto_integrationsでnvim-dapを検出して DapBreakpoint / DapStopped が出る)
      for name, opts in pairs({
        DapBreakpoint = { text = '●' },
        DapBreakpointCondition = { text = '◆' },
        DapBreakpointRejected = { text = '○' },
        DapLogPoint = { text = '◇' },
        DapStopped = { text = '▶', linehl = 'Visual' },
      }) do
        vim.fn.sign_define(name, {
          text = opts.text,
          texthl = name,
          linehl = opts.linehl,
          numhl = '',
        })
      end
    end,
  },
}
