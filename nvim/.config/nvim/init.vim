call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Syntax Highlighting


" Add all the syntax highlighting for mostly everything
Plug 'sheerun/vim-polyglot'

" Uxntal
Plug 'karolbelina/uxntal.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Javascript Syntax
"Plug 'pangloss/vim-javascript'
"Plug 'udalov/kotlin-vim'

" Additional Syntax
"Plug 'plasticboy/vim-markdown'
"Plug 'vim-python/python-syntax'


" Auto Formatting


" Google Java auto-format
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" Formatter for Python
Plug 'psf/black'


" Development Packs


" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Rust
Plug 'rust-lang/rust.vim'

" Colorscheme
Plug 'morhetz/gruvbox'

" For previewing markdown in a web browser
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }


" Autocompletion snippets
Plug 'hrsh7th/cmp-vsnip', {'branch': 'main'}
Plug 'hrsh7th/vim-vsnip'

" Latex
Plug 'lervag/vimtex'
Plug 'KeitaNakamura/tex-conceal.vim'

" LSP Config
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

"Plug 'nvim-lua/lsp_extensions.nvim'
"Plug 'ray-x/lsp_signature.nvim'

" Javascript LSPs
Plug 'denoland/deno'
Plug 'facebook/flow'

" Displays Git diffs in the gutters
Plug 'airblade/vim-gitgutter'

" File browser
Plug 'preservim/nerdtree'

" Allows searching for files by name
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

call plug#end()

" Better auto-completions
set completeopt=menuone,noinsert,noselect

" Use tree-sitter for Lua parsing to get around a bug with Vim's formatter
" https://github.com/neovim/neovim/issues/20456
lua <<EOF
require('nvim-treesitter.configs').setup({
    ensure_installed = {"lua"},
    auto_install = true,
    highlight = {
        enable = true,
        disable = function(lang, bufnr)
            -- including vim for the sake of Lua blocks inside VimL
            if lang == "vim" or lang == "lua" then
                return false
            end
            return true
        end
    },
})
EOF

" LSP configuration
lua << EOF

  local cmp = require'cmp'
  local lspconfig = require'lspconfig'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' }, -- For ultisnips users.
    }, {
      { name = 'buffer' },
    })
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Rust language server
  lspconfig.rust_analyzer.setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
        completion = {
          postfix = {
            enable = false,
          },
        },
      },
    },
    capabilities = capabilities,
  }

  -- Java language server
  lspconfig.java_language_server.setup{
    on_attach = on_attach,
    cmd = {"/usr/share/java/java-language-server/lang_server_linux.sh"},
  }

  -- Required for the Deno Language Server
  vim.g.markdown_fenced_languages = {
    "ts=typescript"
  }

  -- Deno Javascript Language Server
  lspconfig.denols.setup{
    on_attach = on_attach,
    flags = lsp_flags,
  }

  --[[
  -- Flow Javascript Language Server
  lspconfig.flow.setup{
    on_attach = on_attach,
    flags = lsp_flags,
    cmd = {"flow", "lsp"}
  }
  --]]

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      update_in_insert = true,
    }
  )
EOF

" Auto-save buffers when they switch
" Probably not necessary, but helps if I forget to save
set autowrite

" Go development options
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


" Vimtex configuration
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode=0
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \ }

" Turn on spell checking and concealing for Tex files automatically
autocmd FileType tex setlocal spell colorcolumn=81 conceallevel=1

" Turn on text concealing in Tex files
let g:tex_conceal='abdmg'
hi Conceal ctermbg=none

" Auto-formatting
augroup autoformat_settings
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd BufWritePre *.py Black
augroup END

" Assume that all asm files are MIPS assembly syntax
au BufRead,BufNewFile *.asm set filetype=mips

" Python syntax config
let g:python_highlight_all = 1

" Settings for markdown
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1

" Javascript Flow syntax support
let g:javascript_plugin_flow=1

" Enable type inlay hints
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

" Press Ctrl+L to correct the previous spelling mistake
" https://castel.dev/post/lecture-notes-1/#correcting-spelling-mistakes-on-the-fly
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Rustfmt config
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0


" Prevent the text from jumping around
set signcolumn=yes

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Prevent markdown from collapsing content
set nofoldenable

" Vertical bar at 80 characters
set colorcolumn=80
set background=dark
set clipboard=unnamedplus

" Tabs instead of spaces
" tabstop is the number of spaces for the tab character
" expandtab expands tabs into spaces, and noexpandtab disables this
" shiftwidth is the number of spaces to use as indentation
set expandtab
set tabstop=2
set shiftwidth=2

" Normal mouse behavior
set mouse=a


" True-color support: https://github.com/morhetz/gruvbox/wiki/Terminal-specific#0-recommended-neovimvim-true-color-support
if (has("termguicolors"))
  set termguicolors
endif

colorscheme gruvbox
