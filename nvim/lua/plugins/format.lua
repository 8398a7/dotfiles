-- 保存時フォーマット (conform.nvim)
--
-- LSPのフォーマットは使わず、conform側でfiletypeごとに明示する。
--
-- 設定値の出典:
--   vscode/settings.json ... files.trimTrailingWhitespace 等の共通設定
--   プロジェクトのmise.toml ... goimports のバージョン固定

-- markdownは行末2スペースが意図的な改行なので末尾空白を消さない。
-- vscode/settings.json の [markdown].trimTrailingWhitespace=false と同じ扱い。
-- (旧 vim/_config/002-cmd.vim も同じ理由でmarkdownを除外していた)
local no_trim_filetypes = { markdown = true }

-- 保存時フォーマットの有効・無効。生成ファイルや他人のコードを触るときに切る。
local format_on_save_enabled = true

-- prettierは既存ファイルとスタイルが合わないプロジェクトがある。
-- 内容は主にコメント位置の移動や末尾カンマの付与、インデント幅の変更。
-- 保存するだけで無関係な差分が混ざるため、保存時は末尾空白の除去だけにして
-- prettier本体は :Format を叩いたときにだけ走らせる。
--
-- (VSCodeは editor.defaultFormatter = prettier + formatOnSave = true だったので
--  保存時にも走っていたはずだが、上記の差分が残っているとおり
--  これらのファイルは実際にはVSCodeで保存されていない)
local trim_only_on_save_filetypes = { json = true, jsonc = true, yaml = true }

return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    -- configの中で作るコマンドは全部ここに並べる。
    -- 並べ忘れるとプラグインがロードされる前に呼べず黙って無視される (実測)。
    -- lazy.nvimのスタブは bang と range をそのまま転送してくれるので
    -- :FormatDisable! や :'<,'>Format もこのまま通る。
    cmd = { 'ConformInfo', 'Format', 'FormatDisable', 'FormatEnable' },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        -- goplsのformatだとimportの追加が遅いのでgoimportsを使う
        --
        -- VSCodeは editor.codeActionsOnSave で source.organizeImports も
        -- 走らせていたが、こちらには移植しない。標準ライブラリと外部パッケージが
        -- 混ざったimportブロックで両者の出力を比べると完全に一致し、
        -- 未使用importの削除もgoimportsだけで足りる (実測)。
        go = { 'goimports' },
        lua = { 'stylua' },
        -- terraform CLIはこのマシンに入っていない (mise installs/terraformは空)。
        -- terraform-lsは documentFormattingProvider=true と申告するが
        -- 内部でterraform fmtを呼ぶだけなので、CLIが無いと何も整形しない (実測)。
        -- つまりVSCode時代も terraform 整形は動いていなかった。
        -- conformはavailable=falseのフォーマッタを黙って飛ばすので、
        -- CLIを入れた時点で有効になるようマッピングだけ先に置いておく。
        terraform = { 'terraform_fmt' },
        hcl = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
        proto = { 'buf' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        -- vscode/settings.json の [rust] formatOnSave 相当。
        -- rust-analyzerのフォーマットもrustfmtを呼ぶだけなので直接使う
        rust = { 'rustfmt' },
        -- prettierはプロジェクトの node_modules/.bin にある
        -- (conformの from_node_modules が上のディレクトリを辿って見つける)。
        -- グローバルには入っていないので、他のリポジトリでは自動的に
        -- available=false になって黙って飛ばされる (実測)。
        --
        -- ただし既存ファイルとスタイルが合っていないため、保存時は走らせない
        -- (上の trim_only_on_save_filetypes を参照)。
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'prettier' },

        -- markdownは意図的にフォーマッタを入れない。
        -- VSCodeは [markdown] に prettier を割り当てていたが、既存ドキュメントと
        -- スタイルが合わないプロジェクトがある。
        -- 保存するだけで無関係な差分が混ざるので、行末2スペースの保護
        -- (下の '*' の除外) だけを引き継ぐ。:Format でも何も起きないので、
        -- 必要になったら prettier を明示的に足す。
        --
        -- rubyも入れない。rubocopやGemfileが無いプロジェクトでは
        -- ruby-lspもフォーマット機能を申告しない (実測)。

        -- 全filetype共通。VSCodeの files.trimTrailingWhitespace /
        -- files.trimFinalNewlines 相当。
        -- U2でautocmdから外した末尾空白除去の正しい置き場所。
        --
        -- '*' はfiletype固有の指定があっても必ず追加で走る
        -- (conform/init.luaのlist_formatters_for_buffer)。
        -- 関数にしておけばmarkdownだけ外せるので、:Formatを明示的に
        -- 叩いたときも末尾空白が守られる。
        ['*'] = function(bufnr)
          if no_trim_filetypes[vim.bo[bufnr].filetype] then
            return {}
          end
          return { 'trim_whitespace', 'trim_newlines' }
        end,
      },

      default_format_opts = {
        -- LSPフォーマットには落とさない。上で明示したフォーマッタだけを使う
        lsp_format = 'never',
      },

      format_on_save = function(bufnr)
        if not format_on_save_enabled or vim.b[bufnr].disable_autoformat then
          return
        end
        local opts = {
          -- 大きいファイルでも保存が固まらない程度に待つ
          timeout_ms = 3000,
          lsp_format = 'never',
        }
        -- json/yamlは末尾空白の除去だけにする。
        -- formattersを明示するとfiletypeのマッピングと '*' の両方を
        -- 上書きできる (conform/init.luaの has_explicit_formatters)。
        if trim_only_on_save_filetypes[vim.bo[bufnr].filetype] then
          opts.formatters = { 'trim_whitespace', 'trim_newlines' }
        end
        return opts
      end,
    },

    config = function(_, opts)
      require('conform').setup(opts)

      -- insertFinalNewline 相当の設定は不要。
      -- trim_newlinesは末尾の空行を消すだけだが、nvimは 'endofline' と
      -- 'fixendofline' がデフォルトで有効なので書き込み時に最終改行が入る。

      vim.api.nvim_create_user_command('Format', function(info)
        local range = nil
        if info.count ~= -1 then
          -- 範囲指定 (:'<,'>Format) のときはその範囲だけ整形する
          local end_line = vim.api.nvim_buf_get_lines(0, info.line2 - 1, info.line2, true)[1]
          range = { start = { info.line1, 0 }, ['end'] = { info.line2, #end_line } }
        end
        require('conform').format({ async = true, lsp_format = 'never', range = range })
      end, { desc = 'バッファを整形する', range = true })

      vim.api.nvim_create_user_command('FormatDisable', function(info)
        if info.bang then
          -- :FormatDisable! はこのバッファだけ
          vim.b.disable_autoformat = true
          vim.notify('このバッファの保存時フォーマットを無効にしました')
        else
          format_on_save_enabled = false
          vim.notify('保存時フォーマットを無効にしました')
        end
      end, { desc = '保存時フォーマットを無効にする', bang = true })

      vim.api.nvim_create_user_command('FormatEnable', function()
        format_on_save_enabled = true
        vim.b.disable_autoformat = false
        vim.notify('保存時フォーマットを有効にしました')
      end, { desc = '保存時フォーマットを有効にする' })
    end,
  },
}
