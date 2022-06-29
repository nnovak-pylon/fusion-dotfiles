call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Java auto formatting

" Add maktaba and codefmt to the runtimepath.
" (The latter must be installed before it can be used.)
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
" Also add Glaive, which is used to configure codefmt's maktaba flags. See
" `:help :Glaive` for usage.
Plug 'google/vim-glaive'

" Kotlin
Plug 'udalov/kotlin-vim'

" Go development
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Formatter for Python
Plug 'psf/black'

" Colorscheme
Plug 'morhetz/gruvbox'

" Live preview for markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" Snippets
Plug 'SirVer/ultisnips'

" Latex
Plug 'lervag/vimtex'
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }

" LSP Config
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'hrsh7th/cmp-path', {'branch': 'main'}
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'ray-x/lsp_signature.nvim'

" Autocompletion snippets
Plug 'hrsh7th/cmp-vsnip', {'branch': 'main'}
Plug 'hrsh7th/vim-vsnip'

" More syntax
Plug 'rust-lang/rust.vim'
Plug 'plasticboy/vim-markdown'
Plug 'vim-python/python-syntax'
Plug 'karolbelina/uxntal.vim'

" Javascript Syntax
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

" Javascript LSPs
Plug 'denoland/deno'
Plug 'facebook/flow'

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

" Settings for markdown
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1

" Vimtex configuration
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode=0

" Javascript Flow syntax support
let g:javascript_plugin_flow=1

" LSP configuration
lua << END
local cmp = require'cmp'

local lspconfig = require'lspconfig'
cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    -- Tab immediately completes. C-n/C-p to select.
    ['<Tab>'] = cmp.mapping.confirm({ select = true })
  },
  sources = cmp.config.sources(
		{
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
			{ name = 'nvim_lsp' },
  	}
		-- Disable 'path' auto-completion
		--[[
		{
    	{ name = 'path' },
  	}
		--]]
	),
  experimental = {
    ghost_text = true,
  },
})

-- Enable completing paths in :
--cmp.setup.cmdline(':', {
--  sources = cmp.config.sources({
--    { name = 'path' }
--  })
--})

-- Setup lspconfig.
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

  -- Get signatures (and _only_ signatures) when in argument lists.
  require "lsp_signature".on_attach({
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  })
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
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

lspconfig.java_language_server.setup{
	on_attach = on_attach,
	cmd = {"/usr/share/java/java-language-server/lang_server_linux.sh"},
}

-- Required for the Deno Language Server
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- Deno Javascript Language Server
--[[
lspconfig.denols.setup{
	on_attach = on_attach,
	flags = lsp_flags,
}
--]]

-- Flow Javascript Language Server
lspconfig.flow.setup{
	on_attach = on_attach,
	flags = lsp_flags,
	cmd = {"flow", "lsp"}
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
END

" Enable type inlay hints
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

" Press Ctrl+L to correct the previous spelling mistake
" https://castel.dev/post/lecture-notes-1/#correcting-spelling-mistakes-on-the-fly
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Rustfmt config
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

" Better auto-completions
set completeopt=menuone,noinsert,noselect

" Prevent rust-analyzer from jumping the code around
set signcolumn=yes

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Prevent markdown from collapsing content
set nofoldenable

" Vertical bar at 80 characters
set cc=80
set tw=792034
set background=dark
set clipboard=unnamedplus

" Tabs instead of spaces
" tabstop is the number of spaces for the tab character
" expandtab expands tabs into spaces, and noexpandtab disables this
" shiftwidth is the number of spaces to use as indentation
set noexpandtab
set tabstop=2
set shiftwidth=2

" Normal mouse behavior
set mouse=a


" True-color support: https://github.com/morhetz/gruvbox/wiki/Terminal-specific#0-recommended-neovimvim-true-color-support
if (has("termguicolors"))
	set termguicolors
endif

colorscheme gruvbox
