return function()
	require("smartyank").setup({
		highlight = {
			enabled = false, -- highlight yanked text
			higroup = "IncSearch", -- highlight group of yanked text
			timeout = 2000, -- timeout for clearing the highlight
		},
		clipboard = {
			enabled = false, -- `false` to disable copy to host clipboard
		},
	})
end
