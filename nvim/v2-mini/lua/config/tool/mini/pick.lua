local win_config = function()
	local height = math.floor(0.618 * vim.o.lines)
	local width = math.floor(0.4 * vim.o.columns)
	return {
		anchor = "NW",
		height = height,
		width = width,
		border = "solid",
		row = math.floor(0.5 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
	}
end
require("mini.pick").setup({
	mappings = {
		choose_in_vsplit = "<C-CR>",
	},
	options = {
		use_cache = true,
	},
	window = {
		config = win_config,
	},
})
vim.ui.select = MiniPick.ui_select
