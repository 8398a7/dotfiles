" created by 8398a7

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
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
call plug#begin('~/.config/nvim/plugged')
Plug 'vim-coffee-script', { 'for': 'coffee' }
Plug 'basyura/unite-rails'
Plug 'chase/vim-ansible-yaml'
Plug 'easymotion/vim-easymotion'
Plug 'elixir-lang/vim-elixir', { 'for': 'elixir' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-migemo.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'itchyny/lightline.vim'
Plug 'itmammoth/run-rspec.vim'
Plug 'jvirtanen/vim-cocoapods'
Plug 'kassio/neoterm'
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'lervag/vimtex'
Plug 'lervag/vim-latex'
Plug 'mattn/emmet-vim'
Plug 'markcornick/vim-berks'
" Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'neomake/neomake'
Plug 'osyo-manga/unite-quickfix'
Plug 'othree/yajs.vim'
Plug 'othree/es.next.syntax.vim'
Plug 'rhysd/clever-f.vim'
Plug 'rhysd/vim-crystal', { 'for': 'crystal' }
Plug 'Rip-Rip/clang_complete'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc', { 'dir': '~/.vim/plugged/vimproc.vim', 'do': 'make' }
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'soramugi/auto-ctags.vim'
Plug 'thinca/vim-quickrun'
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'tpope/vim-pathogen'
Plug 'wakatime/vim-wakatime'
Plug 'elzr/vim-json', { 'for': 'json' }
call plug#end()
" }}}
" deoplete{{{
let g:deoplete#enable_at_startup = 1
" }}}
" neosnippet {{{
" My snippets
let g:neosnippet#snippets_directory = '~/.config/nvim/snippets/'

" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\: "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif
" }}}
" Unite {{{
" insert modeで開始
let g:unite_enable_start_insert = 1

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

" unite grepにhw(highway)を使う {{{
if executable('hw')
  let g:unite_source_grep_command = 'hw'
  let g:unite_source_grep_default_opts = '--no-group --no-color'
  let g:unite_source_grep_recursive_opt = ''
endif
" }}}
" unite-rails key-mappings {{{
nnoremap ,rc :<C-u>Unite rails/controller<CR>
nnoremap ,rm :<C-u>Unite rails/model<CR>
nnoremap ,rv :<C-u>Unite rails/view<CR>
nnoremap ,rh :<C-u>Unite rails/helper<CR>
nnoremap ,rs :<C-u>Unite rails/stylesheet<CR>
nnoremap ,rj :<C-u>Unite rails/javascript<CR>
nnoremap ,rg :<C-u>Unite rails/gemfile<CR>
nnoremap ,rd :<C-u>Unite rails/db<CR>
" }}}
" カーソル位置の単語をgrep検索
nmap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>

" grep検索結果の再呼出
nmap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

" ファイル検索
nmap <silent> ,e  :<C-u>Unite file_rec/async:!<CR>

" grep検索
nmap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

" location_list
nmap <silent>,l :<C-u>Unite location_list<CR>
" }}}
" golang {{{
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
" }}}
" neoterm {{{
let g:neoterm_position = 'horizontal'
let g:neoterm_automap_keys = ',tt'

nnoremap <silent> <f10> :TREPLSendFile<cr>
nnoremap <silent> <f9> :TREPLSend<cr>
vnoremap <silent> <f9> :TREPLSend<cr>

" run set test lib
nnoremap <silent> ,rt :call neoterm#test#run('all')<cr>
nnoremap <silent> ,rf :call neoterm#test#run('file')<cr>
nnoremap <silent> ,rn :call neoterm#test#run('current')<cr>
nnoremap <silent> ,rr :call neoterm#test#rerun()<cr>

" Useful maps
" hide/close terminal
nnoremap <silent> ,th :call neoterm#close()<cr>
" clear terminal
nnoremap <silent> ,tl :call neoterm#clear()<cr>
" kills the current job (send a <c-c>)
nnoremap <silent> ,tc :call neoterm#kill()<cr>

" Rails commands
command! Troutes :T rake routes
command! -nargs=+ Troute :T rake routes | grep <args>
command! Tmigrate :T rake db:migrate

" Git commands
command! -nargs=+ Tg :T git <args>
" }}}
" run-rspec {{{
let g:run_rspec_bin = 'bundle exec rspec'
nmap <leader>r :RunSpec<CR>
nmap <leader>l :RunSpecLine<CR>
nmap <leader>e :RunSpecLastRun<CR>
nmap <leader>cr :RunSpecCloseResult<CR>
" }}}
" neomake {{{
aug neomake_run
  " 保存時とenter時にlintする
  au! BufWritePost,BufEnter * Neomake

  " インサートモードを抜けた時もlint
  au! InsertLeave * Neomake

  " vim終了時にeslint_dを終了
  au! VimLeave *.js  !eslint_d stop
  au! VimLeave *.jsx  !eslint_d stop

  au BufWritePost * call neomake#Make(1, [], function('s:Neomake_callback'))
  function! s:Neomake_callback(options)
    e
  endf
aug END

let g:neomake_javascript_enabled_makers = ['eslint_d']
let g:neomake_javascript_eslint_maker = {
    \ 'exe': 'eslint_d',
    \ 'args': ['-f', 'compact'],
    \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
    \ '%W%f: line %l\, col %c\, Warning - %m'
    \ }

let g:neomake_ruby_enabled_makers = ['rubocop']
let g:neomake_ruby_rubocop_maker = {
    \ 'exe': 'rubocop',
    \ 'args': ['--auto-correct'],
    \ }

let g:neomake_slim_enabled_makers = ['slimlint']
let g:neomake_logfile = '/tmp/neomake_error.log'
" let g:neomake_verbose = 3
" }}}
" incsearch {{{
function! s:config_easyfuzzymotion(...) abort
  return extend(copy({
  \   'converters': [incsearch#config#fuzzy#converter()],
  \   'modules': [incsearch#config#easymotion#module()],
  \   'keymap': {"\<CR>": '<Over>(easymotion)'},
  \   'is_expr': 0,
  \   'is_stay': 1
  \ }), get(a:, 1, {}))
endfunction

noremap <silent><expr> <SPACE>/ incsearch#go(<SID>config_easyfuzzymotion())

map m/ <Plug>(incsearch-migemo-/)
map m? <Plug>(incsearch-migemo-?)
map mg/ <Plug>(incsearch-migemo-stay)
" }}}
" NERDTree {{{
" 短縮
command Rt :NERDTree

" F2でツリーの開閉
nnoremap <C-f> :NERDTreeToggle<CR>

" ツリーを綺麗に表示
let g:NERDTreeDirArrows = 0

" バッファがNERDTreeのみになったときNERDTreeをとじる
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ツリーのディレクトリの色を変更
hi Directory guifg=#FF0000 ctermfg=red
" }}}
" set {{{
" インデント
set cindent

" 行数
set number
set relativenumber

" タブは空白2文字
set tabstop=2

" タブは空白
set expandtab

" 常にステータスラインを出す
set laststatus=2

" 256色
set t_Co=256

" swapファイルを作らない
set noswapfile

" backspace
set backspace=indent,eol,start

" ハイライトを使わない
set nohlsearch

set showmatch
set shiftwidth=2
set ignorecase
set nobackup
set list
set listchars=tab:^\ ,trail:~
set makeprg=php\ -l\ %
set errorformat=%m\ in\ %f\ on\ line\ %l
" }}}
" map {{{
" 移動関係
nmap j gj
nmap k gk
nmap <Down> gj
nmap <Up> gk
nmap <Space> <PageDown>

" tabnew
nmap <C-b> :tabnew<CR>

" <C-j>でEscape
imap <C-j> <ESC>

" 挿入モードでのカーソル移動
imap <C-n> <Down>
imap <C-p> <Up>
imap <C-b> <Left>
imap <C-f> <Right>
imap <C-a> <Home>
imap <C-e> <End>
" }}}
" command {{{
" vim-rails
command  Rm :Rmodel
" }}}
" filetype {{{
filetype on
filetype indent on
" }}}
" lightline {{{
let g:lightline = {
        \ 'colorscheme': 'solarized',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'MyModified',
        \   'readonly': 'MyReadonly',
        \   'fugitive': 'MyFugitive',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode'
        \ },
        \ 'separator': {'left': '⮀', 'right': '⮂'},
        \ 'subseparator': {'left': '⮁', 'right': '⮃'}
        \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      return fugitive#head()
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction
" }}}
" utility {{{
" シンタックスをオン
syntax on

" 行数のオンオフ
nnoremap <silent> <C-n> :setlocal number! relativenumber!<CR>

" yankをosのclipboardにcopy
set clipboard+=unnamedplus

" 保存時に末尾の空白を除去
autocmd BufWritePre * :%s/\s\+$//ge

" highlight
colorscheme theme

" sudoつけ忘れ用
cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>

" bundle以下のディレクトリも自動で読み込み
execute pathogen#infect()

" ステータス行に現在のgitブランチを表示する
set statusline+=%{fugitive#statusline()}

" jq {{{
command! -nargs=? Jq call s:Jq(<f-args>)
function! s:Jq(...)
  if 0 == a:0
    let l:arg = "."
  else
    let l:arg = a:1
  endif
  execute "%! jq 95fe1a73-e2e2-4737-bea1-a44257c50fc8quot;" . l:arg . "95fe1a73-e2e2-4737-bea1-a44257c50fc8quot;"
endfunction
" }}}
" 全角スペース強調 {{{
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif
" }}}
" folding {{{
if version >=703
  set foldenable         " 折りたたみon
  set foldmethod =marker " 折りたたみ方法:マーカ
  set foldcolumn =0
  set foldlevel  =0
endif
" }}}
" }}}
