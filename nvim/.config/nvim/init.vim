call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Java auto formatting

" Add maktaba and codefmt to the runtimepath.
" (The latter must be installed before it can be used.)
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
" Also add Glaive, which is used to configure codefmt's maktaba flags. See
" `:help :Glaive` for usage.
Plug 'google/vim-glaive'

" Go development
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Better python syntax
Plug 'vim-python/python-syntax'

" Formatter for Python
Plug 'psf/black'

" Colorscheme
Plug 'srcery-colors/srcery-vim'

" Live preview for markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" Snippets
Plug 'SirVer/ultisnips'

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

" UltiSnips keybindings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" Disable the scroll sync in the markdown preview
let g:mkdp_preview_options = {
    \ 'disable_sync_scroll': 1,
    \ }

" Run the Java formatter on save
augroup autoformat_settings
  autocmd FileType java AutoFormatBuffer google-java-format
augroup END

" Run black formatter on save
autocmd BufWritePre *.py execute ':Black'

" Python syntax config
let g:python_highlight_all = 1

" Vimtex configuration
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode=0

set cc=80
set tw=792034
set background=dark
set clipboard=unnamedplus
" Tabs instead of spaces
set noexpandtab
set tabstop=2
set shiftwidth=2
set mouse=a
colorscheme srcery
