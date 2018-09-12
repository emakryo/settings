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
Plug 'tomasr/molokai'
Plug 'vim-latex/vim-latex'
call plug#end()

let g:molokai_original=1
let g:rehash256=1
colorscheme molokai
highlight Normal ctermbg=none

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
"let g:syntastic_python_pylint_args = '--disable=W'
let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_cpp_compiler_options = "-std=c++11"

autocmd FileType vhdl setl expandtab
autocmd FileType vhdl setl tabstop=2
autocmd FileType vhdl setl shiftwidth=2
autocmd FileType haskell setl expandtab
autocmd FileType tex setl spell
autocmd FileType plaintex setl spell
autocmd FileType python setl expandtab
autocmd FileType ruby setl expandtab
autocmd FileType ruby setl tabstop=2
autocmd FileType ruby setl shiftwidth=2
autocmd FileType eruby setl expandtab
autocmd FileType eruby setl tabstop=2
autocmd FileType eruby setl shiftwidth=2
inoremap # V<C-H>#
