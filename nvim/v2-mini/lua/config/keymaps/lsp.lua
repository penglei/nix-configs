local util = require("config.util")

local map_cr = util.bind.map_cr
local map_cb = util.bind.map_callback

-- require("mini.extra").pickers.diagnostic({ scope = "current" })
-- vim.diagnostic.setqflist({ open = true })

-- LSP-related keymaps work only lsp is attached

return {
	["n|<leader>o"] = map_cr("<cmd>Pick lsp scope='document_symbol'<cr>"):desc("Mini: Pick document symbol"),
	["n|,r"] = map_cb(vim.lsp.buf.rename):desc("lsp: buf rename in file range"),
	-- ["n|,R"] = map_cr("Lspsaga rename ++project"):desc("lsp: Rename in project range"),

	-- ["nx|,a"] = map_cb(vim.lsp.buf.code_action):desc("lsp: code actions"),
	---@diagnostic disable-next-line: missing-parameter
	["nx|,a"] = map_cb(function() require("tiny-code-action").code_action() end):desc("tiny code actions"),
	-- ["n|,o"] = map_cr("Symbols"):desc("show buffer lsp symbols"),

	["n|gd"] = map_cb(function() vim.lsp.buf.definition() end):desc("lsp: Code action for cursor"),
	-- ["n|gd"] = map_ca("Lspsaga goto_definition"):desc("lsp: Goto definition"),
	-- ["n|gD"] = map_cr("Lspsaga peek_definition"):desc("lsp: Preview definition"),
	["n|gr"] = map_cr("Lspsaga finder"):desc("lsp: Show reference"),
	["n|gI"] = map_cr("Lspsaga incoming_calls"):desc("lsp: Show all incoming calls on the cursor"),
	["n|go"] = map_cr("Lspsaga outgoing_calls"):desc("lsp: Show outgoing calls"),

	-- Plugin: trouble or lspsaga diagnostics
	--["n|gt"] = map_cr("TroubleToggle"):desc("lsp: Toggle trouble list"),
	-- ["n|<leader>r"] = map_cr("Trouble lsp_references"):desc("lsp: Show lsp references"),
	-- ["n|,d"] = map_cr("Trouble diagnostics"):desc("Trouble: Show document diagnostics"),
	-- ["n|<leader>d<CR>"] = map_cr("Lspsaga show_cursor_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),
	-- ["n|<leader>db"] = map_cr("Lspsaga show_buf_diagnostics"):desc("Lspsaga: Show cusor diagnostics"),
	["n|<leader>d"] = map_cb(function() require("mini.extra").pickers.diagnostic({ scope = "current" }) end):desc("show to pick diagnostics"),
}
