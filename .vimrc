syntax on
set number
set listchars=tab:>-,eol:$
set list
set ruler

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
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
"let g:syntastic_python_pylint_args = '--disable=W'
let g:syntastic_python_checkers = ["python", "flake8"]

autocmd FileType tex setl spell
autocmd FileType python setl expandtab
inoremap # V<C-H>#
