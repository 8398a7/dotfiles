-- lua-language-server
-- nvimの設定自体をLuaで書くのでvimグローバルを認識させる
-- (型情報はlazydev.nvimが動的に注入する)
--
-- lspconfigのlsp/lua_ls.luaがベースになるので、ここには差分だけを書く。
-- (root_markersの .luarc.json / stylua.toml 等はlspconfig側で定義済み)

return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      -- vimグローバルをundefinedにしない
      diagnostics = { globals = { 'vim' } },
      workspace = {
        checkThirdParty = false,
      },
      -- フォーマットはstyluaに任せる
      format = { enable = false },
      telemetry = { enable = false },
    },
  },
}
