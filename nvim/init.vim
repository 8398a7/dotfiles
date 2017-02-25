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
" dein {{{
set rtp+=~/.zplug/bin
" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = expand('~/dotfiles/nvim/dein')
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " call dein#add('MaxMEllon/vim-jsx-pretty')

  let g:rc_dir    = expand('~/dotfiles/nvim')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif
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

  au BufWritePost *.js call neomake#Make(1, [], function('s:Neomake_callback'))
  au BufWritePost *.jsx call neomake#Make(1, [], function('s:Neomake_callback'))
  function! s:Neomake_callback(options)
    e!
  endf
aug END

let g:neomake_javascript_enabled_makers = ['eslint_d']
let g:neomake_javascript_eslint_d_maker = {
    \ 'exe': 'eslint_d',
    \ 'args': ['-f', 'compact', '--fix'],
    \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
    \ '%W%f: line %l\, col %c\, Warning - %m'
    \ }

let g:neomake_ruby_enabled_makers = ['rubocop']
" let g:neomake_ruby_rubocop_maker = {
"     \ 'exe': 'rubocop',
"     \ 'args': ['-a'],
"     \ }

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
" .nameを表示する
let NERDTreeShowHidden = 1
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
set nobackup
" backspace
set backspace=indent,eol,start
" ハイライトを使わない
set nohlsearch
" 検索/置換時に大文字小文字を区別する
set noignorecase
" 対応する括弧を表示
set showmatch
" shiftで挿入される幅
set shiftwidth=2
" 見えない文字を可視化
set listchars=tab:^\ ,trail:~
" タブ文字を CTRL-I で表示し、行末に $ で表示
set list
" エラー時のフォーマット
set errorformat=%m\ in\ %f\ on\ line\ %l
" }}}
" map {{{
" 移動関係
nmap j gj
nmap k gk
nmap <Down> gj
nmap <Up> gk
nmap <Space> <PageDown>
nmap <C-j> :w<CR>
nmap <C-j><C-j> :wq<CR>

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
        \  &ft == 'denite' ? denite#get_status_mode() :
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
set clipboard=unnamed,unnamedplus

" 保存時に末尾の空白を除去
autocmd BufWritePre * :%s/\s\+$//ge

" highlight
colorscheme theme

" sudoつけ忘れ用
cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>

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
" indent guides {{{
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_color_change_percent = 30
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
" }}}
" switch to alphanumeric character when leaving insert mode(osx only) {{{
" brew tap lutzifer/homebrew-tap
" brew install keyboardSwitcher
if has('mac')
  if executable('keyboardSwitcher')
    augroup SwitchIME
      autocmd!
      autocmd InsertLeave * call async#job#start(system('keyboardSwitcher select ABC'), {})
    augroup END
  else
    let s:keycode_jis_eisuu = 102
    let g:cmd = "osascript -e 'tell application \"System Events\" to key code " . s:keycode_jis_eisuu . "'"
    augroup SwitchIME
      autocmd!
      autocmd InsertLeave * call async#job#start(system(s:cmd), {})
    augroup END
  endif
endif
" }}}
