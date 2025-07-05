--[[
require("mini.completion").setup({
	-- mappings = {
	-- 	go_in = "<RET>",
	-- },
	window = {
		info = { border = "solid" },
		signature = { border = "solid" },
	},
	fallback_action = function()
	end,
})
require("mini.snippets").setup()
--]]
--

require("blink.cmp").setup({
	signature = { enabled = true },

	-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
	-- 'super-tab' for mappings similar to vscode (tab to accept)
	-- 'enter' for enter to accept
	-- 'none' for no mappings
	--
	-- All presets have the following mappings:
	-- C-space: Open menu or open docs if already open
	-- C-n/C-p or Up/Down: Select next/previous item
	-- C-e: Hide menu
	-- C-k: Toggle signature help (if signature.enabled = true)
	--
	-- See :h blink-cmp-config-keymap for defining your own keymap
	-- keymap = { preset = "default" },
	keymap = {
		preset = "none",
		-- preset = "super-tab",

		-- ["<C-e>"] = -- { "fallback" }, -- or false, -- or {} -- has bind to emacs style: to line end

		["<C-.>"] = { "show", "show_documentation", "hide_documentation" },
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			"snippet_forward",
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },

		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
		-- ["<Esc>"] = { "hide", "fallback" },
	},

	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		nerd_font_variant = "mono",
	},

	completion = {

		-- (Default) Only show the documentation popup when manually triggered
		documentation = { auto_show = false },
	},

	-- Default list of enabled providers defined so that you can extend it
	-- elsewhere in your config, without redefining it, due to `opts_extend`
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		-- default = { "lsp", "buffer", "codecompanion", "snippets", "path" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				-- make lazydev completions top priority (see `:h blink.cmp`)
				score_offset = 100,
			},
		},
	},

	-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
	-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
	-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
	--
	-- See the fuzzy documentation for more information
	fuzzy = { implementation = "prefer_rust_with_warning", prebuilt_binaries = { force_version = "v1.4.1" } },

	cmdline = {
		enabled = false, -- ui is not good for noice input ui
		sources = { "cmdline" },
		completion = { ghost_text = { enabled = true } },
	},
})
