-- more complicated configurations

---@diagnostic disable-next-line: unused-local, undefined-global
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
	add({ source = "folke/snacks.nvim" })
	--- init notifier firstly
	---https://github.com/folke/snacks.nvim?tab=readme-ov-file#-usage
	require("snacks").setup({
		notifier = { enabled = true },
		input = { enabled = true },
		styles = {
			---@diagnostic disable-next-line: missing-fields
			input = {
				row = require("config.util").win.calsize(1, 0.5).height,
				b = {
					completion = true, -- disable blink completions in input
				},
				keys = { i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true } },
			},
		},
		picker = {
			win = {
				input = {
					keys = {
						["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
						["<Tab>"] = { "list_down", mode = { "i", "n" } },
					},
				},
			},
		},
	})
	-- require("config.tool.notify")
end)

now(function()
	add({ source = "catppuccin/nvim" })

	-- Possible to immediately execute code which depends on the added plugin
	require("config.ui.catppuccin")
end)

now(function() require("mini.icons").setup() end)
now(function()
	-- add({
	-- 	source = "nvim-lualine/lualine.nvim",
	-- 	depends = { "nvim-tree/nvim-web-devicons" },
	-- })
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
	add({ source = "folke/noice.nvim", depends = { "MunifTanjim/nui.nvim", "folke/snacks.nvim" } })
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
			"MeanderingProgrammer/render-markdown.nvim",
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

	-- https://github.com/roobert/tabtree.nvim
	require("tabtree").setup({
		--- tips : try run `:InspectTree` to inpsect all ts nodes.
		key_bindings = {
			previous = "<S-Left>",
			next = "<S-Right>",
		},
		language_configs = {
			go = {
				target_query = [[
					(type_declaration) @type_declaration_capture
					(method_declaration) @method_declaration_capture
					(if_statement) @if_statement_capture
					(for_statement) @for_statement_capture
					(function_declaration) @function_capture
					(block) @block_capture
					(go_statement) @go_statement_capture
					;(interpreted_string_literal) @string_capture
				]],
				offsets = {},
			},
		},
		default_config = {
			offsets = {},
		},
	})
end)

later(function()
	-- add({ source = "numToStr/FTerm.nvim" })
	add({ source = "akinsho/toggleterm.nvim" })
	require("config.tool.terminal")
end)

------------------------------------------------------------------------

later(function()
	add({ source = "nvim-tree/nvim-tree.lua", checkout = "master" })
	add({ source = "b0o/nvim-tree-preview.lua", depends = {
		"nvim-lua/plenary.nvim",
		"3rd/image.nvim",
	} })

	-- require("image").setup()
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

later(function()
	add({ source = "MeanderingProgrammer/render-markdown.nvim" })
	-- add({ source = "lukas-reineke/headlines.nvim" })
	require("render-markdown").setup({ latex = { enabled = false } })
	-- require("headlines").setup()
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

-- later(function()
-- 	add({ source = "mikavilpas/yazi.nvim", depends = { { source = "nvim-lua/plenary.nvim" } } })
-- 	require("yazi").setup({})
-- end)

-- later(function()
-- 	-- conflict with noice.vim
-- 	add("oskarrrrrrr/symbols.nvim")
-- 	require("config.tool.symbols")
-- end)

later(function()
	add({ source = "LZDQ/nvim-autocenter" })
	-- a discussion is here: https://www.reddit.com/r/neovim/comments/1iejf9q/nvimautocenter_auto_zz_when_inserting/
	require("nvim-autocenter").setup()
end)

-------------------- lang ---------------------
later(function()
	add({ source = "saecki/crates.nvim" })
	require("config.lang.rust")
end)
