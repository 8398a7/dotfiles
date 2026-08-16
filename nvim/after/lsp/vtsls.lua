-- vtsls (TypeScript / JavaScript)
-- typescript-language-serverよりVSCode拡張の機能に近い
--
-- lspconfigのlsp/vtsls.luaがベースになるので、ここには差分だけを書く。
-- (root_dirのモノレポ・deno判定とinit_options.hostInfoはlspconfig側を使う)

return {
  settings = {
    vtsls = {
      -- プロジェクトのTypeScriptを使う
      -- (node_modules/typescript/lib を自動検出する)
      autoUseWorkspaceTsdk = true,
    },
    typescript = {
      -- goplsと揃えて関数補完時にプレースホルダを入れる
      suggest = { completeFunctionCalls = true },
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        variableTypes = { enabled = false },
      },
    },
  },
}
