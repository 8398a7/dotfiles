-- yaml-language-server
--
-- lspconfigのlsp/yamlls.luaがベースになるので、ここには差分だけを書く。
-- (cmdのnode_modules/.bin解決はlspconfig側の実装をそのまま使う)

return {
  -- lspconfigのデフォルトには yaml.docker-compose / yaml.gitlab /
  -- yaml.helm-values が入るが、nvimにその名前のfiletypeは無く
  -- checkhealthでUnknown filetypeになる。実在する 'yaml' だけにする。
  filetypes = { 'yaml' },
  settings = {
    yaml = {
      -- SchemaStoreのスキーマを使う
      schemaStore = { enable = true, url = 'https://www.schemastore.org/api/json/catalog.json' },
      -- フォーマットはconform.nvim側で扱う。
      -- lspconfigがデフォルトでtrueにしているため明示的に戻す。
      format = { enable = false },
      -- キーのアルファベット順を強制しない
      keyOrdering = false,
    },
  },
  -- lspconfigはformat.enableに関わらずdocumentFormattingProviderをtrueに
  -- 上書きするon_initを持つ。format.enable=falseと矛盾するので無効化する。
  -- (on_initはfunctionかtableのみ許容されるので空テーブルで打ち消す)
  on_init = {},
}
