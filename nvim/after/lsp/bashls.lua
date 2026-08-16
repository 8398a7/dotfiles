-- bash-language-server
--
-- lspconfigのlsp/bashls.luaがベースになるので、ここには差分だけを書く。
-- (globPatternの再帰スキャン抑止はlspconfig側で設定済み)

return {
  settings = {
    bashIde = {
      -- shellcheckはnvim-lint側で扱うため二重に出さない
      shellcheckPath = '',
    },
  },
}
