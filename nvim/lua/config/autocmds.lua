-- autocmd と filetype 検出
-- 旧 vim/_config/000-filetype.vim と 102-fullspace.vim からの移植

-- filetype検出 {{{
-- 旧設定の6件のうち、nvim 0.12のデフォルトで足りないものだけを移植する。
--   *.jsx        -> デフォルトの javascriptreact に従う (旧: javascript.jsx)
--   .babelrc     -> デフォルトの jsonc に従う (旧: json)
--   .eslintrc    -> デフォルトの jsonc に従う (旧: javascript。実体はJSONなので旧設定が誤り)
--   nginx/*.conf -> デフォルトで検出される
vim.filetype.add({
  extension = {
    -- nvimのデフォルトでは検出されない
    slim = 'slim',
    -- Goテンプレート。nvimは.tmplだけをtemplateとして検出するため、
    -- .gotmpl / .gohtml を足す。
    gotmpl = 'template',
    gohtml = 'template',
    -- marksmanが filetypes に markdown.mdx を含むが、nvimは.mdxを
    -- 検出しないためcheckhealthでUnknown filetypeになる。
    mdx = 'markdown.mdx',
  },
  pattern = {
    -- nginxの設定は拡張子なしのファイルもあるためパスで拾う
    -- (.conf付きはデフォルトで検出されるが、拡張子なしは対象外)
    ['.*/nginx/conf%.d/.*'] = 'nginx',
    ['.*/nginx/servers/.*'] = 'nginx',
  },
})
-- }}}

-- 全角スペースのハイライト {{{
-- 旧実装は match + highlight。matchaddで同じ見え方を維持する。
-- termguicolors下でも効くようguifg/underlineを指定する。
local fullspace = vim.api.nvim_create_augroup('FullSpace', { clear = true })

local function set_fullspace_hl()
  vim.api.nvim_set_hl(0, 'FullSpace', {
    underline = true,
    fg = 'DarkGrey',
    ctermfg = 'DarkGrey',
    cterm = { underline = true },
  })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = fullspace,
  callback = set_fullspace_hl,
  desc = 'colorscheme切り替え後も全角スペースのハイライトを保つ',
})

vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
  group = fullspace,
  callback = function()
    vim.fn.matchadd('FullSpace', '　')
  end,
  desc = '全角スペースをハイライトする',
})

set_fullspace_hl()
-- }}}

-- ヤンクした範囲を一瞬ハイライトする {{{
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = 'ヤンクした範囲をハイライトする',
})
-- }}}

-- 旧設定にあった全ファイル無条件の末尾空白除去は移植しない。
-- VSCodeが [markdown] で trimTrailingWhitespace = false にしている通り
-- Markdownの意図的な2スペース改行を壊すため。
-- 末尾空白除去・最終改行の付与はU7のconform.nvimにfiletype単位で任せる。
