-- local setup = function(name, opts)
-- 	if opts == nil then opts = {} end
-- 	if vim.fn.executable(opts.cmd[1]) == 1 then lspconfig[name].setup(opts) end
-- end

local setup = function(name, opts)
	if opts == nil then
		vim.lsp.enable(name)
	else
		vim.lsp.config(name, opts)
	end
end

setup("lua_ls")

-- setup("rust_analyzer") -- moved to lang.rust

setup("gopls")

setup("bashls", { cmd = { "bash-language-server", "start" }, filetypes = { "bash", "sh" } })

setup("pylsp", {
	cmd = { "pylsp" },
	filetypes = { "python" },
	settings = {
		pylsp = {
			plugins = {
				-- Lint
				ruff = {
					enabled = true,
					select = {
						-- enable pycodestyle
						"E",
						-- enable pyflakes
						"F",
					},
					ignore = {
						-- ignore E501 (line too long)
						"E501",
						-- ignore F401 (imported but unused)
						"F401",
					},
					extendSelect = { "I" },
					severities = {
						-- Hint, Information, Warning, Error
						F401 = "I",
						E501 = "I",
					},
				},

				flake8 = { enabled = false, maxLineLength = 200 },
				pyflakes = { enabled = false },
				pycodestyle = { enabled = false, maxLineLength = 200 },
				mccabe = { enabled = false },

				-- Code refactor
				rope = { enabled = true },

				-- Formatting
				black = { enabled = false }, -- I don't known why it doesn't' work, and I implement this by conform plugin
				pyls_isort = { enabled = false },
				autopep8 = { enabled = false },
				yapf = { enabled = false },
			},
		},
	},
})

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
-- setup("ocamllsp")

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
setup("markdown_oxide")

-- setup()
