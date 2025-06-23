vim.lsp.enable("rust_analyzer")

require("crates").setup({
	lsp = {
		enabled = true,
		on_attach = function(client, bufnr)
			-- the same on_attach function as for your other language servers
			-- can be ommited if you're using the `LspAttach` autocmd
		end,
		actions = true,
		completion = true,
		hover = true,
	},
})
