-- more complicated configurations

---@diagnostic disable-next-line: unused-local, undefined-global
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- for debugging in bootstrap stage. vim.notify would be replaced by trouble.nvim when start finish.
now(function() require("config.tool.notify") end)

now(function()
	add({ source = "catppuccin/nvim" })

	-- Possible to immediately execute code which depends on the added plugin
	require("config.ui.catppuccin")
	vim.cmd.colorscheme("catppuccin-macchiato")
	-- or vim.api.nvim_cmd({ cmd = "colorscheme", args = { "catppuccin-macchiato" } }, {})
end)

now(function() require("mini.icons").setup() end)
now(function()
	add({
		source = "nvim-lualine/lualine.nvim",
		depends = { "nvim-tree/nvim-web-devicons" },
	})
	add({ source = "NStefan002/screenkey.nvim" })
	require("config.ui.statusline")
end)
now(function() require("config.ui.mini.starter") end)

now(function()
	add({
		source = "folke/noice.nvim",
		depends = {
			"MunifTanjim/nui.nvim",
			"folke/snacks.nvim", -- optional
		},
	})
	require("config.ui.noice")
end)
now(function()
	-- require("mini.tabline").setup() --- mini.tabline doesn't export api, and so we can't do key binding...
	add({ source = "akinsho/bufferline.nvim" })
	require("config.ui.bufferline")
end)

------------ Safely execute later ---------------

later(function()
	add({ source = "nvim-tree/nvim-web-devicons" })
	require("nvim-web-devicons").setup()
end)

later(function() require("config.lang.filetypes") end)

later(function() require("mini.ai").setup() end)
later(function() require("mini.align").setup() end)
later(function() require("mini.surround").setup() end)
later(function() require("mini.pairs").setup() end) -- autoclose pairs
later(function() require("mini.splitjoin").setup() end)
later(function() require("mini.visits").setup() end)
later(function() require("mini.bracketed").setup() end)
-- later(function() require("mini.jump").setup() end) -- extend f, F, t, T. -- it's not compatible with `.` repeat occasionally ?
-- later(function() require("mini.extra").setup() end)
-- later(function() require("mini.operators").setup() end)

later(function() require("config.keymaps.clue") end)
later(function()
	-- 方案0
	-- key changed in every step, feel bad... and it's not integrated with treesitter
	-- require("mini.jump2d").setup({ view = { n_steps_ahead = 1 } })

	-- 方案1
	-- 用两个不同的插件实现局部语法调整，导致motion和selection锚点和风格都不一致
	-- add({ source = "smoka7/hop.nvim" })
	-- add({ source = "mfussenegger/nvim-treehopper" , depends = { { source = "nvim-treesitter/nvim-treesitter" } }})
	-- require("config.editing.motion.hop")

	-- 方案2 leap
	-- 既能满足全局motion，也支持局部基于treesitter语法的 motion和section，
	-- 但是在单纯的跳转中存在window抖动的问题。
	add({ source = "ggandor/leap.nvim", depends = { { source = "nvim-treesitter/nvim-treesitter" } } })
	require("config.editing.motion.leap")
	-- 方案3 flash
	-- 有一些缺陷，不能支持按visual模式下调整?
	add({ source = "folke/flash.nvim" })
	require("config.editing.motion.flash")

	-- 因此，综合方案2和方案3实现
end)

later(function()
	add({ source = "neovim/nvim-lspconfig" })
	require("config.editing.lsp")
end)
later(function()
	add({ source = "saghen/blink.cmp", depends = { "rafamadriz/friendly-snippets" }, checkout = "v1.4.1", monitor = "main" })
	require("config.editing.completion")
end)

later(function() require("config.editing.comment") end)
later(function()
	add({
		source = "sustech-data/wildfire.nvim",
		depends = { { source = "nvim-treesitter/nvim-treesitter" } },
	})
	require("wildfire").setup()
end)

later(function()
	add({ source = "stevearc/conform.nvim" })
	require("config.editing.formatter")
end)

later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use 'master' while monitoring updates in 'main'
		checkout = "master",
		monitor = "main",
		-- Perform action after every checkout
		hooks = {
			post_checkout = function() vim.cmd("TSUpdate") end,
		},
	})
	--- Add plugin which depends on nvim-treesitter.
	--- dependencies order is very important, as it affects package search path.
	add({ source = "nvim-treesitter/nvim-treesitter-textobjects" })
	add({ source = "windwp/nvim-ts-autotag" })
	add({ source = "JoosepAlviste/nvim-ts-context-commentstring" })

	-- -- or config dependencies explictly in other later(...) block
	-- add({
	-- 	source = "nvim-treesitter/nvim-treesitter-textobjects",
	-- 	depends = { "nvim-treesitter/nvim-treesitter" },
	-- })

	require("config.editing.treesitter")
end)

later(function()
	-- 	require("mini.bufremove").setup() -- Not well implemented
	-- add({ source = "famiu/bufdelete.nvim" }) -- replaced by Snacks.bufdelete()
end)

later(function()
	-- add({ source = "numToStr/FTerm.nvim" })
	add({ source = "akinsho/toggleterm.nvim" })
	require("config.tool.terminal")
end)

------------------------------------------------------------------------

later(function()
	add({ source = "folke/snacks.nvim" })
	later(function() require("config.tool.picker") end)
end)

later(function()
	add({ source = "nvim-tree/nvim-tree.lua", checkout = "master" })
	require("config.tool.nvim-tree")
	require("mini.files").setup()
end)

later(function()
	add({ source = "catgoose/nvim-colorizer.lua" })
	add({ source = "hiphish/rainbow-delimiters.nvim" })
	add({ source = "https://git.sr.ht/~whynothugo/lsp_lines.nvim" })
	-- colorizer,
	require("config.ui.widgets")
end)

------------------------------------------------------------------------

later(function()
	add({
		source = "nvim-neotest/neotest",
		depends = {
			{ source = "nvim-neotest/nvim-nio" },
			{ source = "nvim-lua/plenary.nvim" },
			{ source = "antoinemadec/FixCursorHold.nvim" },
			{ source = "nvim-treesitter/nvim-treesitter" },
			{ source = "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
		},
	})
	require("config.tool.neotest")
end)

later(function()
	add({ source = "MeanderingProgrammer/render-markdown.nvim" })
	require("render-markdown").setup()
end)
later(function()
	-- a plugin that properly configures LuaLS for editing your Neovim config
	add({ source = "folke/lazydev.nvim" })
	require("lazydev").setup()
end)

------------------------------------------------------------------------

later(function()
	add({ source = "lewis6991/hover.nvim" })
	require("config.tool.hover")
end)

later(function()
	add({ source = "smjonas/inc-rename.nvim" })
	---@diagnostic disable-next-line: missing-parameter
	require("inc_rename").setup()
end)

later(function()
	add({
		source = "rachartier/tiny-code-action.nvim",
		depends = {
			{ source = "nvim-lua/plenary.nvim" },

			{ source = "folke/snacks.nvim" },
			-- { source = "ibhagwan/fzf-lua" },
			-- { source = "nvim-telescope/telescope.nvim" },
		},
	})

	require("tiny-code-action").setup({
		backend = "difftastic",
		picker = "snacks", -- "telescope",
	})
end)

later(function()
	add({ source = "mikavilpas/yazi.nvim", depends = { { source = "nvim-lua/plenary.nvim" } } })
	require("yazi").setup({})
end)

-- later(function()
-- 	-- conflict with noice.vim
-- 	add("oskarrrrrrr/symbols.nvim")
-- 	require("config.tool.symbols")
-- end)

--------------------
later(function()
	add({
		source = "yetone/avante.nvim",
		monitor = "main",
		depends = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"echasnovski/mini.icons",
		},
		hooks = { post_checkout = function() vim.cmd("make") end },
	})
	--- 可选
	-- add({ source = "hrsh7th/nvim-cmp" })
	add({ source = "zbirenbaum/copilot.lua" })
	add({ source = "HakonHarnes/img-clip.nvim" })
	-- require("img-clip").setup({ ... }) -- 配置 img-clip
	-- require("copilot").setup({ ... }) -- 根据您的喜好设置 copilot
	vim.opt.laststatus = 3
	require("avante").setup({
		provider = "claude",
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				timeout = 30000, -- Timeout in milliseconds
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 20480,
				},
			},
		},
	}) -- 配置 avante.nvim
end)
