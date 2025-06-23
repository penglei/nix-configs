--- https://github.com/catgoose/nvim-colorizer.lua

-- Use `user_default_options` as the second parameter, which uses
-- `background` for every mode. This is the inverse of the previous
-- setup configuration.
require("colorizer").setup({
	filetypes = {
		"html",
		"css",
		"javascript",
		html = { mode = "foreground" },
	},
	user_default_options = { mode = "background" },
})
