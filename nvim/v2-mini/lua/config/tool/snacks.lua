--- https://github.com/folke/snacks.nvim?tab=readme-ov-file#-usage
---
require("snacks").setup({
	notifier = { enabled = true },
	input = { enabled = true },
	image = {
		enabled = true,
		doc = { -- it will render image in markdown
			inline = false,
			max_width = 100,
			max_height = 60,
		},
	},
	styles = {
		---@diagnostic disable-next-line: missing-fields
		input = {
			row = require("config.util").win.calsize(1, 0.5).height,
			b = {
				completion = true,
			},
			keys = { i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true } },
		},
	},
	picker = {
		win = {
			input = {
				keys = {
					["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
					["<Tab>"] = { "list_down", mode = { "i", "n" } },
				},
			},
		},
		layout = {
			cycle = true,
			--- Use the default layout or vertical if the window is too narrow
			preset = function() return vim.o.columns >= 120 and "default" or "ivy_split" end,
		},
	},
})
