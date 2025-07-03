----------------------- mini picker ------------------------
local win_config = function()
	local height = math.floor(0.8 * vim.o.lines)
	local width = math.floor(0.8 * vim.o.columns)
	return {
		anchor = "NW",
		height = height,
		width = width,
		row = math.floor(0.3 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
	}
end
require("mini.pick").setup({
	mappings = {
		choose_in_vsplit = "<C-CR>",
	},
	options = {
		use_cache = true,
	},
	window = {
		config = win_config,
	},
})

-------------------------- fzf-lua -------------------------
--[[
require("fzf-lua").setup({
	winopts = {
		preview = {
			hidden = true,
		},
	},
})
--]]

------------------------- snacks --------------------------------
---https://github.com/folke/snacks.nvim?tab=readme-ov-file#-usage
require("snacks").setup({
	opts = {
		explorer = { enabled = false },
		-- indent = { enabled = true },
		scope = { enabled = true },
		picker = { enabled = true },
		marks = { enabled = true },
		quickfile = { enabled = true },
		qflist = { enabled = true },
		diagnostics = { enabled = true },
		diagnostics_buffer = { enabled = true },
		scroll = { enabled = true, animate = {
			duration = { step = 10, total = 100 },
		} },
		notifiera = { enabled = true },
	},
})
Snacks.scroll.enable()
------------------------
-- Snacks.notifier.enable()
-- Snacks.quickfile.enable()
-- Snacks.scope.enable()
