" C-fでツリーの開閉
nnoremap <C-f> :NERDTreeToggle<CR>
" ツリーを綺麗に表示
let g:NERDTreeDirArrows = 0
" バッファがNERDTreeのみになったときNERDTreeをとじる
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" ツリーのディレクトリの色を変更
hi Directory guifg=#FF0000 ctermfg=red
