require("mini.git").setup()
require("mini.trailspace").setup()

--[[
local animate = require("mini.animate")
animate.setup({
	resize = {
		enable = false,
	},
	scroll = {
		timing = animate.gen_timing.cubic({ duration = 120, unit = "total" }),
	},
	cursor = {
		timing = animate.gen_timing.cubic({ duration = 100, unit = "total" }),
	},
})
--]]

-- Prompts the yank scope
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
})

--- https://github.com/catgoose/nvim-colorizer.lua
require("colorizer").setup({
	filetypes = {
		"html",
		"css",
		"javascript",
		html = { mode = "foreground" },
	},
	-- Use `user_default_options` as the second parameter, which uses `background`
	-- for every mode. This is the inverse of the previous setup configuration.
	user_default_options = { mode = "background" },
})

require("lsp_lines").setup()
-- lsp_lines need disable diagnostic virtual text
vim.diagnostic.config({
	virtual_text = false,
})
