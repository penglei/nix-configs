-- require("mini.statusline").setup()

require("screenkey").setup({
	win_opts = {
		relative = "editor",
		col = vim.o.columns / 2 - 20,
		title = "",
		anchor = "SW",
		width = 40,
		height = 1,
	},
})

require("lualine").setup({
	sections = {
		lualine_c = {
			-- other components ...
			function() return require("screenkey").get_keys() end,
		},
	},
})
require("screenkey").toggle_statusline_component()
