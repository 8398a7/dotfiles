" 保存時に末尾の空白を除去
autocmd BufWritePre * :%s/\s\+$//ge
