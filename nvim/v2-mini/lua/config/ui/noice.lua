local win = require("config.util").win
local pos = win.calsize(0, 1)
---@diagnostic disable-next-line: missing-fields
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = true, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
	notify = {
		enabled = false, -- provided by mini.notify
	},
	views = {
		cmdline_popup = {
			position = {
				row = pos.height - 3,
				col = "50%",
			},
			size = {
				width = 60,
				height = 1,
			},
		},
		cmdline_popupmenu = {
			position = {
				row = pos.height - 6,
				col = "50%",
			},
			size = { width = 60, height = "auto", max_height = 33 },
		},
	},
})
