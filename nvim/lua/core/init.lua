local global = require("core.global")

local disable_distribution_plugins = function()
  vim.g.catppuccin_debug = true
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
  -- NOTE: Disabling rplugin.vim will show error for `wilder.nvim` in :checkhealth,
  -- NOTE:  but since it's config doesn't require python rtp, it's fine to ignore.
  -- vim.g.loaded_remote_plugins = 1
end

local other_leaders_map = function()
  -- ',/' as Toggle comment
  -- vim.api.nvim_set_keymap("n", "gc", "", { noremap = true })
  -- vim.api.nvim_set_keymap("n", "gcc", "", { noremap = true })

  vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
  vim.api.nvim_set_keymap("x", ",", "", { noremap = true })
end

local clipboard_config = function()
  if global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  end
end

-------------- init ----------------

disable_distribution_plugins()
other_leaders_map()
-- clipboard_config()

require("core.options")
require("core.mapping")
require("core.event")
require("core.pack")

local colorscheme = require("core.settings").colorscheme
local background = require("core.settings").background
vim.api.nvim_command("set background=" .. background)
vim.api.nvim_command("colorscheme " .. colorscheme)
