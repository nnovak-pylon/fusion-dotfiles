-- Make line numbers default
vim.wo.number = true

vim.g.have_nerd_font = false

vim.o.colorcolumn = "80"
vim.o.background = "dark"
vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

-- Enable mouse mode
vim.o.mouse = "a"

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

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Add a gutter so that things don't jump around
vim.wo.signcolumn = "yes"

-- Prevent markdown from collapsing down
vim.o.foldenable = false

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Tabs instead of spaces
-- :h tabstop is the number of spaces for a tab character
-- :h expandtab expands tabs into spaces
-- :h shiftwidth is the number of spaces to use as indentation
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

-- Disable modelines, this removes some errors when opening text files
vim.o.modeline = false
