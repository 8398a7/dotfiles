-- エディタの基本挙動
-- 旧 vim/_config/003-set.vim からの移植 + VSCode (vscode/settings.json) の挙動再現

local opt = vim.opt

-- 行番号 (VSCode: editor.lineNumbers = relative)
opt.number = true
opt.relativenumber = true

-- インデント: タブは空白2文字 (VSCode: editor.tabSize = 2)
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2

-- 不可視文字の可視化 (VSCode: editor.renderWhitespace = boundary)
opt.list = true
opt.listchars = { tab = '^ ', trail = '~', nbsp = '+' }

-- swap / backup を作らない
opt.swapfile = false
opt.backup = false

-- 検索
opt.ignorecase = true
opt.smartcase = true -- 大文字を含む検索語なら大文字小文字を区別する

-- 対応する括弧を表示
opt.showmatch = true

-- 折りたたみはマーカ方式 (旧設定の {{{ }}} を維持)
opt.foldenable = true
opt.foldmethod = 'marker'
opt.foldcolumn = '0'
opt.foldlevel = 0

-- syntax highlightの打ち切り列。
-- treesitterはこの値を見ないため、1行26万文字のJSONでも描画速度は
-- 変わらなかった (実測)。パーサが無いfiletype (.slimなど) が
-- 正規表現syntaxにフォールバックしたときの保険として残す。
opt.synmaxcol = 200

-- 24bitカラー (旧 t_Co=256 の置き換え)
-- t_Coはnvimでもエラーにならず黙って無視されるため明示的に廃止する
opt.termguicolors = true

-- 診断サインの表示でテキストが左右にずれないよう常に確保する
opt.signcolumn = 'yes'

-- CursorHold系の発火とLSPの反応を速くする
opt.updatetime = 250

-- 分割は下・右に開く
opt.splitbelow = true
opt.splitright = true

-- フローティングウィンドウの枠を一括指定 (0.11以降のオプション)
opt.winborder = 'rounded'

-- 改行コードはLF (VSCode: files.eol = "\n")
opt.fileformat = 'unix'

-- 行折り返しをしない (VSCode: editor.wordWrap = off)
opt.wrap = false

-- カーソル行の上下に最低3行残す
opt.scrolloff = 3

-- クリップボード {{{
-- WSLからWindows側のクリップボードへは端末のOSC 52で渡す。
-- 旧設定はclipboard=exclude:.*と+=unnamedが併存して矛盾していた。
-- exclude:.*はnvimではE474になるので移植できない。
opt.clipboard = 'unnamedplus'

local osc52 = require('vim.ui.clipboard.osc52')

-- copy/pasteはレジスタ名を受け取って関数を返すファクトリ
-- pasteはOSC 52の応答を返さない端末が多いため、nvim内のレジスタで代替する
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
  paste = {
    ['+'] = function()
      return vim.split(vim.fn.getreg('"'), '\n')
    end,
    ['*'] = function()
      return vim.split(vim.fn.getreg('"'), '\n')
    end,
  },
}
-- }}}
