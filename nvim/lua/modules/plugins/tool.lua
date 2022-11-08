local M = {}

--[[
tool["tpope/vim-fugitive"] = {
	lazy = true,
	cmd = { "Git", "G" },
}
--]]

-- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
M["folke/which-key.nvim"] = {
  lazy = true,
  event = "VeryLazy",
  config = require("tool.which-key"),
}

M["nvim-tree/nvim-tree.lua"] = {
  lazy = true,
  cmd = {
    "NvimTreeToggle",
    "NvimTreeOpen",
    "NvimTreeFindFile",
    "NvimTreeFindFileToggle",
    "NvimTreeRefresh",
  },
  event = { "VeryLazy" },
  config = require("tool.nvim-tree"),
}

--tool["michaelb/sniprun"] = {
--	lazy = true,
--	-- You need to cd to `~/.local/share/nvim/site/lazy/sniprun/` and execute `bash ./install.sh`,
--	-- if you encountered error about no executable sniprun found.
--	build = "bash ./install.sh",
--	cmd = { "SnipRun" },
--	config = require("tool.sniprun"),
--}

M["akinsho/toggleterm.nvim"] = {
  lazy = true,
  cmd = {
    "ToggleTerm",
    "ToggleTermSetName",
    "ToggleTermToggleAll",
    "ToggleTermSendVisualLines",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualSelection",
  },
  config = require("tool.toggleterm"),
}
M["folke/trouble.nvim"] = {
  lazy = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = require("tool.trouble"),
}

-- Automatically provides suggestions as you type ':'(command mode) or '/'(search mode)
M["gelguy/wilder.nvim"] = {
  lazy = true,
  event = "CmdlineEnter",
  config = require("tool.wilder"),
  dependencies = { "romgrk/fzy-lua-native" },
}

-- custom jump stack mark
-- M["LeonHeidelbach/trailblazer.nvim"] = {
--   lazy = true,
--   event = "BufReadPost",
--   config = require("tool.trailblazer"),
-- }

M["ahmedkhalf/project.nvim"] = {
  lazy = true,
  ft = { "alpha" },
  event = "BufReadPost",
  config = require("tool.project"),
}

----------------------------------------------------------------------
--                        Telescope Plugins                         --
----------------------------------------------------------------------
M["nvim-telescope/telescope.nvim"] = {
  lazy = true,
  cmd = "Telescope",
  ft = { "alpha" },
  config = require("tool.telescope"),
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-lua/plenary.nvim" },
    { "debugloop/telescope-undo.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "ahmedkhalf/project.nvim" },
    {
      "nvim-telescope/telescope-frecency.nvim",
      dependencies = {
        {
          "kkharji/sqlite.lua",
          config = function()
            --nix profile install nixpkgs#sqlite.out
            vim.g.sqlite_clib_path = vim.fn.expand("$HOME/.nix-profile/lib/libsqlite3.dylib")
          end,
        },
      },
    },
    { "jvgrootveld/telescope-zoxide" },
    { "nvim-telescope/telescope-live-grep-args.nvim" },
  },
}

return M
