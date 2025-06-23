local win = require("config.util").win
local r = require("symbols.recipes")

require("symbols").setup(r.DefaultFilters, r.AsciiSymbols, {
	-- https://github.com/oskarrrrrrr/symbols.nvim
	sidebar = {
		-- custom settings here
		hide_cursor = false,
		preview = {
			show_line_number = true,
			max_window_height = win.calsize().height,
		},
	},
})

-- n|,o -> map_cr(Symbols)
