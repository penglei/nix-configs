-- more complicated configurations

--[[
  ui: window layout ... e.g. which-key,alpha, layout, window
  editor: buffer内核心编辑、跳转、自动完成等
  tool: 集成的更加高层视角的工具，如 selector, terminal, test, dap 等等
  lang: 按语言生态进行配置的插件，可能包含针对该语言多种特殊配置
]]

---@diagnostic disable-next-line: unused-local, undefined-global
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Safely execute immediately
now(function()
	vim.o.termguicolors = true
	vim.cmd("colorscheme randomhue")
end)
now(function()
	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()
end)
now(function()
	require("mini.icons").setup()
end)
now(function()
	require("mini.tabline").setup()
end)
now(function()
	require("mini.statusline").setup()
end)

now(function()
	require("config.ui.mini.starter")
end)

-- Safely execute later
later(function()
	require("mini.ai").setup()
end)
later(function()
	require("mini.comment").setup()
end)
later(function()
	require("config.tool.mini.pick")
end)
later(function()
	require("mini.surround").setup()
end)
later(function()
	require("config.ui.mini.clue")
end)
later(function()
	require("mini.extra").setup()
end)

now(function()
	-- Use other plugins with `add()`. It ensures plugin is available in current
	-- session (installs if absent)
	add({
		source = "neovim/nvim-lspconfig",
		-- Supply dependencies near target plugin
		-- depends = { },
	})
end)

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use 'master' while monitoring updates in 'main'
		checkout = "master",
		monitor = "main",
		-- Perform action after every checkout
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	-- depends order affects package search path which is very important
	add({ source = "mfussenegger/nvim-treehopper" })
	add({ source = "nvim-treesitter/nvim-treesitter-textobjects" })
	add({ source = "windwp/nvim-ts-autotag" })
	add({ source = "JoosepAlviste/nvim-ts-context-commentstring" })

	-- -- or config dependencies explictly in other later(...) block
	-- add({
	-- 	source = "mfussenegger/nvim-treehopper",
	-- 	depends = { "nvim-treesitter/nvim-treesitter" },
	-- })
	-- add({
	-- 	source = "nvim-treesitter/nvim-treesitter-textobjects",
	-- 	depends = { "nvim-treesitter/nvim-treesitter" },
	-- })

	-- Possible to immediately execute code which depends on the added plugin
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "lua", "vimdoc" },
		highlight = { enable = true },
	})
end)

later(function()
	add({ source = "andymass/vim-matchup", depends = { "nvim-treesitter/nvim-treesitter" } })
	vim.g.matchup_transmute_enabled = 1
	vim.g.matchup_surround_enabled = 1
	vim.g.matchup_matchparen_offscreen = { method = "popup" }
end)

later(function()
	add({ source = "hiphish/rainbow-delimiters.nvim" })
	add({ source = "NvChad/nvim-colorizer.lua" })
end)

later(function()
	add({
		source = "nvim-tree/nvim-tree.lua",
		checkout = "master",
		monitor = "main",
	})

	require("config.ui.nvim-tree")
end)
