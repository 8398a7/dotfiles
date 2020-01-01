" 移動関係
nmap <Space> <PageDown>
" tabnew
nmap <C-B> :tabnew<CR>
" 行数のオンオフ
nmap <silent> <C-n> :setlocal number! relativenumber!<CR>
" C-jでEscape
imap <C-j> <ESC>
" 挿入モードでEmacsキーバインド
imap <C-n> <Down>
imap <C-p> <Up>
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-a> <Home>
imap <C-e> <End>

" sudoつけ忘れ用
cmap w!! w !sudo tee > /dev/null %<CR> :e!<CR>
