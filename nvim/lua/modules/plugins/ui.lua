local M = {}

M["goolord/alpha-nvim"] = {
  lazy = true,
  event = "BufWinEnter",
  config = require("ui.alpha"),
}

M["akinsho/bufferline.nvim"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("ui.bufferline"),
}

M["catppuccin/nvim"] = {
  lazy = false,
  name = "catppuccin",
  config = require("ui.catppuccin"),
}

M["echasnovski/mini.nvim"] = {
  lazy = false,
  version = false,
}

-- theme: nord
M["shaunsingh/nord.nvim"] = {
  lazy = true,
  config = require("ui.nord"),
}

M["j-hui/fidget.nvim"] = {
  -- Standalone UI for nvim-lsp progress
  -- TODO:
  --   bug: conflict with clever-f while press 'f' in boot progress
  lazy = true,
  event = "BufReadPost",
  config = require("ui.fidget"),
}

M["lewis6991/gitsigns.nvim"] = {
  lazy = true,
  event = { "CursorHold", "CursorHoldI" },
  config = require("ui.gitsigns"),
}

--[[
ui["lukas-reineke/indent-blankline.nvim"] = {
	lazy = true,
	event = "BufReadPost",
	config = require("ui.indent-blankline"),
}
--]]

M["nvim-lualine/lualine.nvim"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("ui.lualine"),
}

-- Neovim plugin for dimming the highlights of unused functions, variables, parameters, and more
M["zbirenbaum/neodim"] = {
  lazy = true,
  event = "LspAttach",
  config = require("ui.neodim"),
}

-- ui["karb94/neoscroll.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	config = require("ui.neoscroll"),
--}

M["rcarriga/nvim-notify"] = {
  lazy = false,
  --event = "VeryLazy",
  config = require("ui.notify"),
}

-- ui["folke/paint.nvim"] = { -- comment highlight
-- 	lazy = true,
-- 	event = { "CursorHold", "CursorHoldI" },
-- 	config = require("ui.paint"),
-- }

-- --Show where your cursor moves when jumping large distances
-- --  This plugin has a ugly implementation which create some unnecessary windows.
-- ui["edluffy/specs.nvim"] = {
-- 	lazy = true,
-- 	event = "CursorMoved",
-- 	config = require("ui.specs"),
-- 	enabled = false,
-- }

M["kevinhwang91/nvim-bqf"] = {
  ft = "qf",
}

return M
