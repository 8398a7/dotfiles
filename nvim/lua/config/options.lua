-- エディタの基本挙動

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

-- 折りたたみはマーカ方式 ({{{ }}})
opt.foldenable = true
opt.foldmethod = 'marker'
opt.foldcolumn = '0'
opt.foldlevel = 0

-- 正規表現syntaxの打ち切り列。Treesitterには適用されない。
opt.synmaxcol = 200

-- 24bitカラー
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
-- ローカル環境はネイティブprovider、SSHなどはOSC 52を使う。
opt.clipboard = 'unnamedplus'

-- Prefer the native provider on macOS, Linux desktops and WSL with clipboard
-- tools. Use OSC 52 for SSH and WSL without a native provider. Paste falls back
-- to the internal register because many terminals cannot answer OSC 52 reads.
local wsl = vim.env.WSL_DISTRO_NAME or vim.env.WSL_INTEROP
local remote = vim.env.SSH_CONNECTION or vim.env.SSH_TTY
local native = vim.fn.executable('win32yank.exe') == 1
  or vim.fn.executable('wl-copy') == 1
  or vim.fn.executable('xclip') == 1
  or vim.fn.executable('xsel') == 1
  or vim.fn.has('macunix') == 1
local mode = vim.env.DOTFILES_CLIPBOARD or 'auto'
if mode == 'osc52' or (mode == 'auto' and (remote or (wsl and not native))) then
  local osc52 = require('vim.ui.clipboard.osc52')
  local function internal_paste()
    return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = internal_paste, ['*'] = internal_paste },
  }
end
-- }}}
