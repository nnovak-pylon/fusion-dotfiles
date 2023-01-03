-- Make line numbers default
vim.wo.number = true

vim.o.colorcolumn = "80"
vim.o.background = "dark"
vim.o.clipboard = "unnamedplus"

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

-- Decrease update time
vim.o.updatetime = 250

-- Add a gutter so that things don't jump around
vim.wo.signcolumn = 'yes'

-- Prevent markdown from collapsing down
vim.o.foldenable = false

-- Tabs instead of spaces
-- :h tabstop is the number of spaces for a tab character
-- :h expandtab expands tabs into spaces
-- :h shiftwidth is the number of spaces to use as indentation
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noinsert,noselect'
