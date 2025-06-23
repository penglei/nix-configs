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
	views = {
		cmdline_popup = {
			position = {
				row = "80%",
				col = "50%",
			},
			size = {
				width = 60,
				height = "auto",
			},
		},
		cmdline_popupmenu = {
			position = {
				row = "60%",
				col = "50%",
			},
			-- size = { width = "50", },
		},
	},
})
