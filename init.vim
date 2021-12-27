call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'vim-python/python-syntax'

Plug 'srcery-colors/srcery-vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" Latex
Plug 'lervag/vimtex'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }

call plug#end()

set autowrite

" Go configuration
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

let g:go_auto_type_info = 1

" Python syntax config
let g:python_highlight_all = 1

" Vimtex configuration
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode=0

set cc=80
set tw=792034
set background=dark
set clipboard=unnamedplus
set expandtab
set tabstop=2
set shiftwidth=2
set mouse=a
colorscheme srcery
