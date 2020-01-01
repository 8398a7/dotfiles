function! FullSpace()
  highlight FullSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup FullSpace
    autocmd!
    " FullSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call FullSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match FullSpace /　/
  augroup END
  call FullSpace()
endif
