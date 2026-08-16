-- gopls
--
-- lspconfigのlsp/gopls.luaがベースになるので、ここには差分だけを書く。
-- (root_dirのGOMODCACHE除外などはlspconfig側の実装をそのまま使う)

return {
  -- lspconfigのデフォルトは 'gotmpl' だが、nvimにその名前のfiletypeは無く
  -- checkhealthでUnknown filetypeになる。Goテンプレートは 'template' が正しい。
  -- (.gotmpl / .gohtml の検出は lua/config/autocmds.lua で足している)
  filetypes = { 'go', 'gomod', 'gowork', 'template' },
  settings = {
    gopls = {
      -- templateとして扱う拡張子。指定しないとgoplsはテンプレートを解析しない
      templateExtensions = { 'tmpl', 'gotmpl', 'gohtml' },
      usePlaceholders = true, -- 関数補完時にパラメータのプレースホルダを入れる
      completeUnimported = true, -- 未importのパッケージも補完候補に出す
      deepCompletion = true,
      -- フォーマットはgoimportsに任せる (importの追加がgoplsより速い)。
      -- conform.nvim 側で設定する。
      gofumpt = false,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
      },
    },
  },
}
