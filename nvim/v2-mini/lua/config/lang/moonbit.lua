require("moonbit").setup({
	mooncakes = {
		virtual_text = true, -- virtual text showing suggestions
		use_local = true, -- recommended, use index under ~/.moon
	},
	-- optionally disable the treesitter integration
	treesitter = {
		enabled = true,
		-- nvim-treesitter 锁定在 v0.10.0 master，主模块没有 .install 字段，
		-- moonbit.nvim 调用 require('nvim-treesitter').install 会报错。
		-- parser 已手动安装 (parser/moonbit.so)，关掉 auto_install 即可。
		auto_install = false,
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
