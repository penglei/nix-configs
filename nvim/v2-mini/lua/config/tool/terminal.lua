local config = {
	-- size can be a number or function which is passed the current terminal
	size = function(term)
		if term.direction == "horizontal" then
			return 12 -- vim.o.lines * 0.30
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.40
		end
	end,
	---@diagnostic disable-next-line: unused-local
	on_open = function(term)
		-- Prevent infinite calls from freezing neovim.
		-- Only set these options specific to this terminal buffer.
		vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
		vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
		vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
	end,
	highlights = {
		Normal = {
			link = "Normal",
		},
		NormalFloat = {
			link = "NormalFloat",
		},
		FloatBorder = {
			link = "FloatBorder", -- catppuccin overrides to style like 'solid'
		},
	},
	float_opts = {
		border = "none", -- "none", -- "rounded", -- "single", --# none to disable window title
		winblend = 0,
	},
	open_mapping = false, -- [[<c-\>]],
	hide_numbers = true, -- hide the number column in toggleterm buffers
	shade_filetypes = {},
	shade_terminals = false,
	shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	persist_mode = false,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
}

local tt = require("toggleterm.terminal")
local closeTerm = function(id)
	local term = tt.get(id)
	if term then term:close() end
end
local toggleTerm = function(term)
	if term == nil then return end
	if term:is_open() then
		term:close()
	else
		term:open()
	end
end

_G.CloseBottomTerm = function() closeTerm(1) end
_G.ToggleBottomTerm = function()
	local term = tt.get_or_create_term(1, vim.fn.getcwd(), "horizontal", "default bottom term#1")
	toggleTerm(term)
end
vim.api.nvim_create_user_command("ToggleBottomTerm", ToggleBottomTerm, {})

_G.CloseFloatTerm = function() closeTerm(2) end
_G.ToggleFloatTerm = function()
	local term = tt.get_or_create_term(2, vim.fn.expand("%:p:h"), "float", "default float term#2")
	toggleTerm(term)
end
vim.api.nvim_create_user_command("ToggleFloatTerm", ToggleFloatTerm, {})

require("toggleterm").setup(config)
