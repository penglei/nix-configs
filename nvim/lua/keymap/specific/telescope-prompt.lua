vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"TelescopePrompt",
	},
	callback = function(event)
		vim.api.nvim_buf_set_keymap(event.buf, "i", "<C-f>", "<Right>", {
			silent = true,
			noremap = true,
			desc = "move cursor to right char",
		})

		vim.api.nvim_buf_set_keymap(event.buf, "i", "<A-f>", "<S-Right>", {
			silent = true,
			noremap = true,
			desc = "move cursor over right a word",
		})

		vim.api.nvim_buf_set_keymap(event.buf, "i", "<A-b>", "<S-Left>", {
			silent = true,
			noremap = true,
			desc = "move cursor over left a word",
		})
	end,
})
