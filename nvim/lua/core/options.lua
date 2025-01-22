vim.g.mapleader = " "
vim.g.maplocalleader = " "

--https://stackoverflow.com/questions/30691466/what-is-difference-between-vims-clipboard-unnamed-and-unnamedplus-settings
-- vim.opt.clipboard = "unnamedplus" -- I don't want to send system clipboard that would be watched other clipboard manager.

vim.opt.cul = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = false -- true is not good for commenting yaml
vim.opt.fillchars = { eob = " " }
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.laststatus = 3
vim.opt.statusline = " "
vim.opt.cmdheight = 1

vim.opt.foldenable = true
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 99 -- foldenable and open all default (only fold > 100 level)

vim.opt.list = true
vim.opt.listchars = { -- "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
  tab = "  »",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
}

vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.diffopt = "filler,iwhite,internal,algorithm:patience"

vim.opt.wildignorecase = true
vim.opt.wildignore = {
  ".git",
  ".hg",
  ".svn",
  "*.pyc",
  "*.o",
  "*.out",
  "*.jpg",
  "*.jpeg",
  "*.png",
  "*.gif",
  "*.zip",
  "**/tmp/**",
  "*.DS_Store",
  "**/node_modules/**",
  "**/bower_modules/**",
}

-- interval for writing swap file to disk, also used by gitsigns
vim.opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append("<>[]hl")

-- disable nvim intro
vim.opt.shortmess:append("sI")

vim.opt.jumpoptions = "stack"

vim.opt.grepprg = "rg --hidden --vimgrep --smart-case --"
