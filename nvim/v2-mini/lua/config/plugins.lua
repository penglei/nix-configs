-- more complicated configurations

---@diagnostic disable-next-line: unused-local, undefined-global
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	-- add({ source = "folke/snacks.nvim" })
	add({ source = "penglei/snacks.nvim" })
	--- init notifier firstly
	-- require("config.tool.notify")
	require("config.tool.snacks")
end)

now(function()
	add({ source = "catppuccin/nvim" })

	-- Possible to immediately execute code which depends on the added plugin
	require("config.ui.catppuccin")
end)

later(function() require("mini.icons").setup() end)
now(function()
	add({ source = "NStefan002/screenkey.nvim" }) -- show key pressing

	require("config.ui.statusline") -- mini.statusline
	require("config.ui.mini.starter")
end)

now(function()
	-- require("mini.tabline").setup() --- mini.tabline doesn't export api, and so we can't do key binding...
	add({ source = "akinsho/bufferline.nvim" })
	require("config.ui.bufferline")
end)

------------ Safely execute later ---------------

later(function()
	-- 	add({ source = "folke/noice.nvim", depends = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" } }) -- just ui, no auto completion
	-- add({
	-- 	source = "gelguy/wilder.nvim", -- no path auto-completion, so I have switched to blink.cmp
	-- 	hooks = {
	-- 		post_checkout = function()
	-- 			vim.cmd([[ let &rtp=&rtp ]])
	-- 			vim.api.nvim_command("runtime! plugin/rplugin.vim")
	-- 			vim.api.nvim_command(":UpdateRemotePlugins")
	-- 		end,
	-- 	},
	-- })
	-- require("config.ui.interact")
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

	require("config.keymaps.toggle")
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
	-- add({ source = "nvim-treesitter/nvim-treesitter-refactor" })
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
	-- Neovim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
	add({ source = "RRethy/vim-illuminate" })

	-- display prettier diagnostic messages. Display one line diagnostic messages where the cursor is, with icons and colors.
	add({ source = "rachartier/tiny-inline-diagnostic.nvim" })
	-- lsp_lines is a simple neovim plugin that renders diagnostics using virtual lines on top of the real line of code
	add({ source = "https://git.sr.ht/~whynothugo/lsp_lines.nvim" })

	add({ source = "yt20chill/inline_git_blame.nvim" })

	-- A tiny Neovim plugin that adds subtle animations to various operations.
	add({ source = "rachartier/tiny-glimmer.nvim" })

	add({ source = "folke/todo-comments.nvim", depends = { "nvim-lua/plenary.nvim" } })
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
	-- Neovim plugin for dimming the highlights of unused functions, variables, parameters, and more
	add({ source = "zbirenbaum/neodim" })
	require("neodim").setup({
		hide = {
			virtual_text = false,
			signs = false,
			underline = false,
		},
	})
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

later(function()
	add({ source = "Mofiqul/dracula.nvim" })
	require("dracula").setup()
end)

-------------------- lang ---------------------
later(function()
	add({ source = "Julian/lean.nvim" })
	require("lean").setup({ mappings = true })
end)
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
		-- latex = { enable = true }, -- unset it would also disable math in markdown
	})
end)

-- later(function()
-- 	add({ source = "pxwg/math-conceal.nvim" })
-- 	require("math-conceal").setup()
-- end)

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
