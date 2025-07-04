local MiniStatusline = require("mini.statusline")
local icons = require("config.ui.icons")
local keyboard_icon = icons.get("ui").Keyboard

local statusline_active = function()
	local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
	local git = MiniStatusline.section_git({ trunc_width = 40 })
	local diff = MiniStatusline.section_diff({ trunc_width = 75 })
	local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
	local filename = MiniStatusline.section_filename({ trunc_width = 140 })
	local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
	local location = MiniStatusline.section_location({ trunc_width = 75 })
	local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

	local screenkey = function() return require("screenkey").get_keys() end

	-- Usage of `MiniStatusline.combine_groups()` ensures highlighting and
	-- correct padding with spaces between groups (accounts for 'missing'
	-- sections, etc.)
	return MiniStatusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
		"%<", -- Mark general truncate point
		{ hl = "MiniStatuslineFilename", strings = { filename } },
		"%=", -- End left alignment
		{ hl = "MiniStatuslineFileinfo", strings = { fileinfo, keyboard_icon, screenkey() } },
		{ hl = mode_hl, strings = { search, location } },
	})
end

require("screenkey").setup({
	-- win_opts = {
	-- 	relative = "editor",
	-- 	col = vim.o.columns / 2 - 20,
	-- 	title = "",
	-- 	anchor = "SW",
	-- 	width = 40,
	-- 	height = 1,
	-- },
})
require("screenkey").toggle_statusline_component()

vim.api.nvim_create_autocmd("User", {
	pattern = "ScreenkeyCleared",
	callback = function() vim.cmd("redrawstatus") end,
})

MiniStatusline.setup({
	content = {
		active = statusline_active,
	},
})
