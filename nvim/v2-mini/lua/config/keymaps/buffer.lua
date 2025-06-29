local util = require("config.util")

local map_cr = util.bind.map_cr
local map_callback = util.bind.map_callback

-- LSP-related keymaps work only when event = { "InsertEnter", "LspStart" }
return {
	["n|<leader>o"] = map_cr("Lspsaga outline"):desc("lsp: Toggle outline"),
	["n|,r"] = map_cr("Lspsaga rename"):desc("lsp: Rename in file range"),
	["n|,R"] = map_cr("Lspsaga rename ++project"):desc("lsp: Rename in project range"),

	-- ["n|K"] = map_cr("Lspsaga hover_doc"):desc("lsp: Show doc"),
	["n|K"] = map_callback(function()
		if vim.bo.filetype == "haskell" then
			vim.lsp.buf.hover() -- native doc popup renders link correct.
		else
			vim.cmd(":Lspsaga hover_doc")
		end
	end):desc("lsp: Show doc"),

	["nv|,a"] = map_cr("Lspsaga code_action"):desc("lsp: Code action for cursor"),
	["n|gD"] = map_cr("Lspsaga peek_definition"):desc("lsp: Preview definition"),
	["n|gd"] = map_cr("Lspsaga goto_definition"):desc("lsp: Goto definition"),
	["n|gr"] = map_cr("Lspsaga finder"):desc("lsp: Show reference"),
	["n|gI"] = map_cr("Lspsaga incoming_calls"):desc("lsp: Show all incoming calls on the cursor"),
	["n|go"] = map_cr("Lspsaga outgoing_calls"):desc("lsp: Show outgoing calls"),

	-- Plugin: trouble or lspsaga diagnostics
	--["n|gt"] = map_cr("TroubleToggle"):desc("lsp: Toggle trouble list"),
	-- ["n|<leader>r"] = map_cr("Trouble lsp_references"):desc("lsp: Show lsp references"),
	-- ["n|,d"] = map_cr("Trouble diagnostics"):desc("Trouble: Show document diagnostics"),
	["n|,d<CR>"] = map_cr("Lspsaga show_cursor_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),
	["n|,db"] = map_cr("Lspsaga show_buf_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),

	["n|<C-t>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>t<CR>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>ts"] = map_cr("ToggleNeotestSummar"):desc("Neotest: tooglle test summary"),
	["n|<leader>to"] = map_cr("ShowTestOutput"):desc("Neotest: show cursor test output"),
}
