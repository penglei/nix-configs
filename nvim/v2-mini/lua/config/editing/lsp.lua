-- local setup = function(name, opts)
-- 	if opts == nil then opts = {} end
-- 	if vim.fn.executable(opts.cmd[1]) == 1 then lspconfig[name].setup(opts) end
-- end

vim.lsp.inlay_hint.enable(true)

-- `vim.lsp.config` only updates the config; `vim.lsp.enable` is what actually
-- auto-starts the server. Always call both so servers with custom opts attach.
local setup = function(name, opts)
	if opts then
		vim.lsp.config(name, opts)
	end
	vim.lsp.enable(name)
end

setup("clangd")

-- Configure lua_ls for editing the nvim config (and lua plugins on rtp).
-- We avoid lazydev.nvim here: its `workspace/configuration` handler returns `{}`
-- for unscoped requests (lazydev/lsp.lua "fallback scope" branch), and lua_ls
-- 3.17.x uses that empty response, dropping `workspace.library`/`runtime.path`.
-- That breaks `gd` on `require("...")` strings, `vim.*`, and plugin globals.
-- `on_init` runs at client start and mutates `client.config.settings.Lua`
-- (same ref as `client.settings`), which the default handler serves to lua_ls.
setup("lua_ls", {
	on_init = function(client)
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = { "?.lua", "?/init.lua" },
				pathStrict = true,
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("lua", true),
			},
		})
	end,
})

-- setup("rust_analyzer") -- moved to lang.rust

setup("gopls")

setup("bashls", { cmd = { "bash-language-server", "start" }, filetypes = { "bash", "sh" } })

setup("pyright")
-- setup("pylsp")

setup("html", {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	init_options = {
		configurationSection = { "html", "css", "javascript" },
		embeddedLanguages = { css = true, javascript = true },
	},
	settings = {},
	single_file_support = true,
	flags = { debounce_text_changes = 500 },
})

-- setup("hls")
setup("ocamllsp")

setup("nickel_ls")
setup("nil_ls")
setup("buck2")
setup("pbls")
setup("tinymist", { settings = { exportPdf = "onSave", outputPath = "$root/target/$dir/$name" } })

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/jsonls.lua
setup("jsonls", {
	-- cmd = { "json-languageserver", "--stdio" },
	flags = { debounce_text_changes = 500 },
	settings = {
		json = {
			-- Schemas https://www.schemastore.org
			schemas = {
				{
					fileMatch = { "package.json" },
					url = "https://json.schemastore.org/package.json",
				},
				{
					fileMatch = { "tsconfig*.json" },
					url = "https://json.schemastore.org/tsconfig.json",
				},
				{
					fileMatch = {
						".prettierrc",
						".prettierrc.json",
						"prettier.config.json",
					},
					url = "https://json.schemastore.org/prettierrc.json",
				},
				{
					fileMatch = { ".eslintrc", ".eslintrc.json" },
					url = "https://json.schemastore.org/eslintrc.json",
				},
				{
					fileMatch = {
						".babelrc",
						".babelrc.json",
						"babel.config.json",
					},
					url = "https://json.schemastore.org/babelrc.json",
				},
				{
					fileMatch = { "lerna.json" },
					url = "https://json.schemastore.org/lerna.json",
				},
				{
					fileMatch = {
						".stylelintrc",
						".stylelintrc.json",
						"stylelint.config.json",
					},
					url = "http://json.schemastore.org/stylelintrc.json",
				},
				{
					fileMatch = { "/.github/workflows/*" },
					url = "https://json.schemastore.org/github-workflow.json",
				},
			},
		},
	},
})

setup("yamlls", {
	settings = {
		yaml = {
			schemas = {
				-- default any schema to prevent lsp schema diagnostic error
				[vim.fn.stdpath("config") .. "/config/schema-any.yaml"] = "/*",
			},
		},
	},
})

if vim.fn.executable("dart") == 1 then
	setup("dartls", {
		cmd = { "dart", "language-server", "--protocol=lsp" },
		filetypes = { "dart" },
		init_options = {
			closingLabels = true,
			flutterOutline = true,
			onlyAnalyzeProjectsWithOpenFiles = true,
			outline = true,
			suggestFromUnimportedLibraries = true,
		},
	})
end

if vim.fn.executable("deno") == 1 then setup("denols", { cmd = { "deno", "lsp" } }) end

setup("purescriptls", {
	settings = {
		purescript = {
			addSpagoSources = true, -- e.g. any purescript language-server config here
		},
	},
	flags = {
		debounce_text_changes = 150,
	},
})

-- setup("marksman")
-- Disabled: markdown_oxide misanalyzes fenced code blocks — it flags
-- `[...](...)`-style code as a broken link (Info diagnostic → underline) and
-- marks it as a comment (semantic token → gray), and pollutes outline.nvim
-- with embedded-language symbols. markview + treesitter are enough.
-- setup("markdown_oxide")

setup("jdtls")

-- setup()
