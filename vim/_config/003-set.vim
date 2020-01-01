" 行数
set number
set relativenumber
" タブは空白2文字
set expandtab
set tabstop=2
set shiftwidth=2
" 常にステータスラインを出す
set laststatus=2
" 256色
set t_Co=256
" 高速化
set clipboard=exclude:.*
" swapファイル、バックアップファイルを作らない
set noswapfile
set nobackup
" 不可視文字を表示する
set list
" tab、末尾空白を可視化
set listchars=tab:^\ ,trail:~
" 1行に200文字までしかsyntax highlightを有効にしない
set synmaxcol=200
" 括弧入力時に対応する括弧を表示
set showmatch
" 検索時に大文字小文字を区別しない
set ignorecase
" pasteモード切り替え
set pastetoggle=<C-a>
set clipboard+=unnamed
" folding有効化
if version >=703
  set foldenable         " 折りたたみon
  set foldmethod =marker " 折りたたみ方法:マーカ
  set foldcolumn =0
  set foldlevel  =0
endif
