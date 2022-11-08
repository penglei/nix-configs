return function()
	require("ibl").setup({
        scope = {
            exclude = {
		filetype = {
			"", -- for all buffers without a file type
			"NvimTree",
			"TelescopePrompt",
			"dashboard",
			"dotooagenda",
			"flutterToolsOutline",
			"fugitive",
			"git",
			"gitcommit",
			"help",
			"json",
			"log",
			"markdown",
			"peekaboo",
			"startify",
			"todoist",
			"txt",
			"vimwiki",
			"vista",
		},
		buftype = { "terminal", "nofile" },
        },
        --[[
		context_patterns = {
			"^if",
			"^table",
			"block",
			"class",
			"for",
			"function",
			"if_statement",
			"import",
			"list_literal",
			"method",
			"selector",
			"type",
			"var",
			"while",
		},
        --]]
    }
	})
end
