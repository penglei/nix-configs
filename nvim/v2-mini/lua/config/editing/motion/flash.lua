---@diagnostic disable-next-line: missing-fields
require("flash").setup({
	modes = {
		char = {
			jump_labels = true,
			label = { exclude = "wbehjkliardc" }, -- 'w', 'b', 'e', should be exluded!
		},
	},
})
