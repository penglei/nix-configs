require("moonbit").setup({
	mooncakes = {
		virtual_text = true, -- virtual text showing suggestions
		use_local = true, -- recommended, use index under ~/.moon
	},
	-- treesitter integration: moonbit.nvim (907c824, 2026-07-04) already uses
	-- the nvim-treesitter main branch API (require('nvim-treesitter').install).
	treesitter = {
		enabled = true,
		auto_install = true,
	},
	-- configure the language server integration
	-- set `lsp = false` to disable the language server integration
	lsp = {
		-- provide an `on_attach` function to run when the language server starts
		on_attach = function(client, bufnr) end,
		-- provide client capabilities to pass to the language server
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	},
})
