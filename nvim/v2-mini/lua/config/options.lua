--- simple global legacy style configuration
--- ==============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.conceallevel = 2

-- Don't send system clipboard, or it would be watched by other clipboard manager.
-- vim.opt.clipboard = "unnamedplus"

-- stylua: ignore start
vim.opt.wildignore = {
	".git", ".hg", ".svn", "*.pyc", "*.o", "*.out",
	"*.jpg", "*.jpeg", "*.png", "*.gif", "*.zip", "**/tmp/**",
	"*.DS_Store", "**/node_modules/**", "**/bower_modules/**", "buck-out"
}
-- stylua: ignore end

-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

vim.opt.termguicolors = true
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

vim.opt.statusline = " "
vim.opt.laststatus = 3 -- always and ONLY the last window have a statusline
vim.opt.cmdheight = 0 -- hide cmdline

vim.opt.foldenable = true
vim.opt.foldmethod = "syntax"

-- foldenable and open all default (only fold > 100 level)
vim.opt.foldlevel = 99

vim.opt.list = true

-- vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
vim.opt.listchars = { tab = "  »", nbsp = "+", trail = "·", extends = "→", precedes = "←" }

vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.diffopt = "filler,iwhite,internal,algorithm:patience"

vim.opt.wildignorecase = true

-- interval for writing swap file to disk, also used by gitsigns
vim.opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append("<>[]hl")

-- disable nvim intro
vim.opt.shortmess:append("sI")

vim.opt.jumpoptions = "stack"

vim.opt.grepprg = "rg --hidden --vimgrep --smart-case --"

---========================= reset builtin ================================---

-- disable menu loading
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

-- Uncomment this if you define your own filetypes in `after/ftplugin`
-- vim.g.did_load_filetypes = 1

-- Do not load native syntax completion
vim.g.loaded_syntax_completion = 1

-- Do not load spell files
vim.g.loaded_spellfile_plugin = 1

-- Whether to load netrw by default
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwFileHandlers = 1
-- vim.g.loaded_netrwPlugin = 1
-- vim.g.loaded_netrwSettings = 1
-- newtrw liststyle: https://medium.com/usevim/the-netrw-style-options-3ebe91d42456
vim.g.netrw_liststyle = 3

-- Do not load tohtml.vim
vim.g.loaded_2html_plugin = 1

-- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
-- related to checking files inside compressed files)
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

-- Do not use builtin matchit.vim and matchparen.vim since the use of vim-matchup
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

-- Disable sql omni completion.
vim.g.loaded_sql_completion = 1

-- Disable remote plugins
-- vim.g.loaded_remote_plugins = 1 -- wilder.nvim need remote rplugin
