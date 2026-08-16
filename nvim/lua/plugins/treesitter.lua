-- treesitter によるシンタックスハイライト・インデント
-- mainブランチを使う (masterは0.11互換で凍結)

local parsers = {
  'bash',
  'diff',
  'dockerfile',
  'git_rebase',
  'gitcommit',
  'go',
  'gomod',
  'gosum',
  'gotmpl',
  'hcl',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'proto',
  'ruby',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- mainブランチはlazy-loading非対応
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- 未インストールのパーサだけを入れる
      local installed = require('nvim-treesitter.config').get_installed('parsers')
      local missing = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, parsers)
      if #missing > 0 then
        require('nvim-treesitter').install(missing)
      end

      -- .tmplはnvimのデフォルトでtemplateになる。
      -- VSCode側は "*.tmpl": "gogo" だったので、gotmplパーサを紐付けて
      -- Goテンプレートとしてハイライトする。
      vim.treesitter.language.register('gotmpl', 'template')

      -- mainブランチはsetup()でhighlightを有効化しない。
      -- パーサがある filetype だけ vim.treesitter.start() する。
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
        callback = function(args)
          local ft = args.match
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end
          -- パーサが無いfiletype (.slimなど) では従来のsyntaxに任せる
          if not vim.treesitter.language.add(lang) then
            return
          end
          vim.treesitter.start(args.buf, lang)
          -- インデントはtreesitterに任せる
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
        desc = 'パーサがあるfiletypeでtreesitterを有効化する',
      })
    end,
  },
}
