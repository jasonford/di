local opt = vim.opt

local undo_dir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo_dir, "p")

opt.mouse = "a"
opt.termguicolors = true
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false
opt.showtabline = 2
opt.laststatus = 3
opt.cmdheight = 1
opt.pumheight = 10
opt.hidden = true
opt.confirm = true

opt.splitright = true
opt.splitbelow = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true

opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.showbreak = "-> "
opt.sidescroll = 1
opt.list = true
opt.listchars = {
  extends = ">",
  precedes = "<",
  tab = "> ",
  trail = ".",
  nbsp = "+",
}
opt.fillchars = {
  eob = " ",
}

opt.scrolloff = 5
opt.mousescroll = "ver:3,hor:6"
opt.sidescrolloff = 8
opt.updatetime = 250
opt.timeoutlen = 300

opt.completeopt = {
  "menu",
  "menuone",
  "noselect",
}

opt.undofile = true
opt.undodir = undo_dir

if vim.fn.has("clipboard") == 1 then
  opt.clipboard = "unnamedplus"
end
