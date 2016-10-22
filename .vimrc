syntax on
set number
set listchars=tab:>-,eol:$
set list

set autoindent
set smartindent
set tabstop=4
set shiftwidth=4

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/syntastic'
call plug#end()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
