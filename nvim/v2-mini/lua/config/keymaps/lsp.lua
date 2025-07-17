local util = require("config.util")

local map_cb = util.bind.map_callback

-- LSP-related keymaps work only lsp is attached

return {
	["n|,r"] = map_cb(vim.lsp.buf.rename):desc("lsp: buf rename in file range"),
	-- ["n|,R"] = map_cr("Lspsaga rename ++project"):desc("lsp: Rename in project range"),

	-- ["nx|,a"] = map_cb(vim.lsp.buf.code_action):desc("lsp: code actions"),
	---@diagnostic disable-next-line: missing-parameter
	["nx|,a"] = map_cb(function() require("tiny-code-action").code_action() end):desc("tiny code actions"),
	-- ["nx|,a"] = map_cr("FzfLua lsp_code_actions"):desc("code actions"),
	-- ["n|,o"] = map_cr("Symbols"):desc("show buffer lsp symbols"),

	-- ["n|<leader>o"] = map_cb(function() Snacks.picker.lsp_symbols() end):desc("LSP Symbols"),
	-- ["n|<leader>ss"] = map_cb(function() Snacks.picker.lsp_symbols() end):desc("LSP Symbols"),
	["n|<leader>ss"] = map_cb(function() Snacks.picker.lsp_workspace_symbols() end):desc("LSP Workspace Symbols"),
	["n|gd"] = map_cb(function() Snacks.picker.lsp_definitions() end):desc("Goto Definition"),
	["n|gD"] = map_cb(function() Snacks.picker.lsp_declarations() end):desc("Goto Declaration"),
	["n|gr"] = map_cb(function() Snacks.picker.lsp_references() end):nowait(true):desc("References"),
	["n|gI"] = map_cb(function() Snacks.picker.lsp_implementations() end):desc("Goto Implementation"),
	["n|gy"] = map_cb(function() Snacks.picker.lsp_type_definitions() end):desc("Goto T[y]pe Definition"),

	-- Plugin: trouble or lspsaga diagnostics
	--["n|gt"] = map_cr("TroubleToggle"):desc("lsp: Toggle trouble list"),
	-- ["n|<leader>r"] = map_cr("Trouble lsp_references"):desc("lsp: Show lsp references"),
	-- ["n|,d"] = map_cr("Trouble diagnostics"):desc("Trouble: Show document diagnostics"),
	-- ["n|<leader>d<CR>"] = map_cr("Lspsaga show_cursor_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),
	-- ["n|<leader>db"] = map_cr("Lspsaga show_buf_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),
	["n|<leader>d"] = map_cb(function() require("mini.extra").pickers.diagnostic({ scope = "current" }) end):desc("show to pick diagnostics"),
}
