-- more complicated configurations

---@diagnostic disable-next-line: unused-local, undefined-global
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	add({ source = "folke/snacks.nvim" })
	--- init notifier firstly
	-- require("config.tool.notify")
	require("config.tool.snacks")
end)

now(function()
	add({ source = "catppuccin/nvim" })

	-- Possible to immediately execute code which depends on the added plugin
	require("config.ui.catppuccin")
end)

now(function() require("mini.icons").setup() end)
now(function()
	add({ source = "NStefan002/screenkey.nvim" })
	require("config.ui.statusline") -- mini.statusline
end)
now(function() require("config.ui.mini.starter") end)

now(function()
	-- require("mini.tabline").setup() --- mini.tabline doesn't export api, and so we can't do key binding...
	add({ source = "akinsho/bufferline.nvim" })
	require("config.ui.bufferline")
end)

------------ Safely execute later ---------------

later(function()
	-- 	add({ source = "folke/noice.nvim", depends = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" } }) -- just ui, no auto completion
	add({
		source = "gelguy/wilder.nvim",
		hooks = {
			post_checkout = function()
				vim.cmd([[ let &rtp=&rtp ]])
				vim.api.nvim_command("runtime! plugin/rplugin.vim")
				vim.api.nvim_command(":UpdateRemotePlugins")
			end,
		},
	})
	require("config.ui.interact")
end)

later(function()
	add({ source = "nvim-tree/nvim-web-devicons" })
	require("nvim-web-devicons").setup()
end)

later(function() require("config.tool.picker") end)
later(function() require("config.lang.filetypes") end)

later(function() require("mini.align").setup() end)
later(function() require("mini.visits").setup() end)
later(function() require("mini.bracketed").setup() end)

-- later(function() require("mini.jump").setup() end) -- extend f, F, t, T. -- it's not compatible with `.` repeat occasionally ?
-- later(function() require("mini.extra").setup() end) -- more mini pickers
-- later(function() require("mini.operators").setup() end)

later(function()
	add({ source = "folke/which-key.nvim" })

	-- require("config.keymaps.clue")

	require("which-key").setup({
		preset = "helix", --"modern",
	})

	-- Create some toggle mappings
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle.line_number():map("<leader>ul")
	Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
	Snacks.toggle.treesitter():map("<leader>uT")
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
	Snacks.toggle.inlay_hints():map("<leader>uh")
	Snacks.toggle.indent():map("<leader>ug")
	Snacks.toggle.dim():map("<leader>uD")

	Snacks.toggle
		.new({
			id = "lsp_line_virtext",
			name = "Lsp Line Virtual Text",
			get = function() return vim.diagnostic.config().virtual_lines end,
			set = function(state) vim.diagnostic.config({ virtual_lines = state }) end,
		})
		:map("<leader>ue")
end)

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
	add({
		source = "saghen/blink.cmp",
		depends = {
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			-- mikavilpas/blink-ripgrep.nvim
		},
		checkout = "v1.4.1",
		monitor = "main",
	})
	add({
		source = "olimorris/codecompanion.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- "MeanderingProgrammer/render-markdown.nvim",
			"ravitemer/codecompanion-history.nvim",
		},
	})
	add({ source = "Saghen/blink.compat" })

	-- ai suggestions
	add({ source = "zbirenbaum/copilot.lua" })
	add({ source = "milanglacier/minuet-ai.nvim" })
	add({ source = "supermaven-inc/supermaven-nvim" })

	local ai = require("config.editing.ai")

	require("config.editing.completion").setup({
		ai_virtext_sugg = ai.virtext_sugg, -- ai virtual text suggestions,
	})
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
	add({ source = "nvim-treesitter/nvim-treesitter-textobjects" }) -- This complements mini.ai.
	add({ source = "windwp/nvim-ts-autotag" })
	add({ source = "JoosepAlviste/nvim-ts-context-commentstring" })
	add({ source = "sustech-data/wildfire.nvim" })
	add({ source = "andymass/vim-matchup" })
	add({ source = "Mr-LLLLL/treesitter-outer" })
	add({ source = "roobert/tabtree.nvim" })

	-- dependencies can specified explictly in other later(...) block
	-- later(function()
	-- 	add({
	-- 		source = "nvim-treesitter/nvim-treesitter-textobjects",
	-- 		depends = { "nvim-treesitter/nvim-treesitter" },
	-- 	})
	-- end)

	require("config.editing.textobjects")
end)

later(function()
	-- add({ source = "numToStr/FTerm.nvim" })
	add({ source = "akinsho/toggleterm.nvim" })
	require("config.tool.terminal")
end)

------------------------------------------------------------------------

later(function()
	add({ source = "nvim-tree/nvim-tree.lua", checkout = "master" })
	add({
		source = "b0o/nvim-tree-preview.lua",
		depends = {
			"nvim-lua/plenary.nvim",
			-- "3rd/image.nvim",
		},
	})

	-- require("image").setup() -- The functionality of `3rd/image.nvim` and `snacks image` overlaps.
	require("config.tool.filexplorer")
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

later(function() end)

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
	-- 	add("oskarrrrrrr/symbols.nvim") -- conflict with noice.vim?
	add({ source = "hedyhli/outline.nvim" })
	require("outline").setup()
end)

later(function()
	add({ source = "kevinhwang91/nvim-ufo", depends = { "kevinhwang91/promise-async" } })

	require("config.tool.fold")
end)

later(function()
	add({ source = "HakonHarnes/img-clip.nvim" })
	require("img-clip").setup()
end)

-- later(function()
-- 	add({ source = "mikavilpas/yazi.nvim", depends = { { source = "nvim-lua/plenary.nvim" } } })
-- 	require("yazi").setup({})
-- end)

later(function()
	add({ source = "LZDQ/nvim-autocenter" })
	-- a discussion is here: https://www.reddit.com/r/neovim/comments/1iejf9q/nvimautocenter_auto_zz_when_inserting/
	require("nvim-autocenter").setup()
end)

later(function()
	add({ source = "leath-dub/snipe.nvim" }) --buffer explorer
	require("snipe").setup()
end)

later(function()
	add({ source = "otavioschwanck/arrow.nvim", depends = { "nvim-tree/nvim-web-devicons" } })
	require("arrow").setup({
		show_icons = true,
		leader_key = "mf", -- File Mappings mark
		buffer_leader_key = "ml", -- Per Buffer Mappings mark
	})
end)

-------------------- lang ---------------------
later(function()
	add({ source = "saecki/crates.nvim" })
	require("config.lang.rust")
end)

now(function() -- markview do lazy loading internally, so we setup it synchronously.
	add({ source = "OXY2DEV/markview.nvim", depends = { "saghen/blink.cmp" } }) -- markview will register blink.cmp automatically
	local presets = require("markview.presets")
	require("markview.extras.checkboxes").setup()
	require("markview.extras.editor").setup({ max_height = 30 })
	require("markview.extras.headings").setup()
	require("markview").setup({
		markdown = { headings = presets.headings.slanted },
	})
end)

later(function()
	add({ source = "epwalsh/obsidian.nvim", depends = { "nvim-lua/plenary.nvim" } })
	-- add({ source = "MeanderingProgrammer/render-markdown.nvim" }) -- there exists many conflict with obsidian.nvim
	require("config.tool.obsidian")
end)

later(function()
	add({
		source = "NeogitOrg/neogit",
		depends = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"folke/snacks.nvim",
		},
	})

	require("neogit").setup({
		graph_style = "unicode",
		integrations = {
			-- snacks,
		},
	})
end)
