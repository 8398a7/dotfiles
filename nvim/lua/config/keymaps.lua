-- キーマップ
-- 旧 vim/_config/001-mappings.vim の習慣を保持する
-- leader は init.lua で <Space> に設定済み

local map = vim.keymap.set

-- 移動 {{{
-- 旧設定は <Space> を PageDown に割り当てていたが、<Space> は leader に譲った。
-- ページ送りは nvim 標準の <C-d> / <C-u> を使う。
-- }}}

-- タブ {{{
-- 旧設定の <C-b> = tabnew は移植しない。
-- nvimはタブよりバッファ中心の運用になるので、<C-b> はバッファ一覧
-- (fzf-lua) に譲った (lua/plugins/finder.lua)。
-- タブが必要なときは :tabnew / gt / gT を使う。
--
-- <C-f> も旧設定 (NERDTreeトグル) の意図を引き継いでファイルツリーに
-- 割り当てている (lua/plugins/ui.lua の neo-tree)。
-- どちらもプラグインのkeysに書いてあるので、ここには置かない。
-- }}}

-- ウィンドウ移動 {{{
-- <C-h/j/k/l> は herdr のペイン移動と繋がっているので
-- lua/local/herdr/init.lua で定義している。
-- }}}

-- 表示トグル {{{
map('n', '<C-n>', '<Cmd>setlocal number! relativenumber!<CR>', {
  silent = true,
  desc = '行番号の表示を切り替える',
})
-- }}}

-- 挿入モードのEmacsキーバインド {{{
map('i', '<C-j>', '<Esc>', { desc = 'ノーマルモードに戻る' })
map('i', '<C-b>', '<Left>', { desc = '左へ' })
map('i', '<C-f>', '<Right>', { desc = '右へ' })
map('i', '<C-a>', '<Home>', { desc = '行頭へ' })
map('i', '<C-e>', '<End>', { desc = '行末へ' })
-- <C-n> / <C-p> はblink.cmpが候補選択に使うが、fallback_to_mappingsなので
-- メニュー非表示時はここのマップに落ちる。両立するので変更しない (実測)。
map('i', '<C-n>', '<Down>', { desc = '下へ' })
map('i', '<C-p>', '<Up>', { desc = '上へ' })
-- }}}

-- sudoを付け忘れたときの保存 {{{
-- nvimでもtee経由の書き込みは通る (W10警告は出るが内容は保存される)
map('c', 'w!!', 'w !sudo tee > /dev/null %<CR>:e!<CR>', { desc = 'sudoで保存し直す' })
-- }}}

-- 検索ハイライトを消す {{{
map('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = '検索ハイライトを消す' })
-- }}}
