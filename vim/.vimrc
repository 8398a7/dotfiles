"
"                    ##     ## #### ##     ## ########   ######
"                    ##     ##  ##  ###   ### ##     ## ##    ##
"                    ##     ##  ##  #### #### ##     ## ##
"                    ##     ##  ##  ## ### ## ########  ##
"                     ##   ##   ##  ##     ## ##   ##   ##
"                ###   ## ##    ##  ##     ## ##    ##  ##    ##
"                ###    ###    #### ##     ## ##     ##  ######
"
" startup time {{{
if has('vim_starting') && has('reltime')
  let s:startuptime = reltime()
  augroup vimrc-startuptime
    autocmd! VimEnter *
          \   echomsg 'startuptime: ' . reltimestr(reltime(s:startuptime))
          \ | unlet s:startuptime
  augroup END
endif
" }}}
" vim-plug {{{
call plug#begin('~/.vim/plugged')
Plug 'chr4/nginx.vim'
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
if !filereadable($HOME . '/dotfiles/zsh/external.zsh')
  Plug 'wakatime/vim-wakatime'
end
call plug#end()
" }}}

syntax on
colorscheme theme

call map(sort(split(globpath(&runtimepath, '_config/*.vim'))), {->[execute('exec "so" v:val')]})
