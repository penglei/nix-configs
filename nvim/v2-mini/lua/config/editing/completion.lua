-- 不要在显示cmp menu的时候隐藏copilot suggestion。同时保持可见，可以实现
-- cmp切换一个候选项后，copilot suggestion可以自动更新，即根据新的选择的候选项来生成新的suggestion.
--
-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "BlinkCmpMenuOpen",
-- 	callback = function() vim.b.copilot_suggestion_hidden = true end,
-- })
--
-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "BlinkCmpMenuClose",
-- 	callback = function() vim.b.copilot_suggestion_hidden = false end,
-- })

local cs = require("copilot.suggestion")
local super_tab_entry = function(cmp)
	if cmp.snippet_active() then
		-- jump in the selected snippet
		vim.notify("snippet active: accept")
		return cmp.accept()
	else
		-- select in menu
		if cmp.is_menu_visible() then
			-- vim.notify(":select_and_acceptactive:\n" .. vim.inspect(cmp))
			return cmp.select_and_accept()
		else
			-- vim.notify("press tab to fallback, copilot suggestion visible: " .. vim.inspect(cs.is_visible()))
			cs.accept(function(suggestion)
				-- vim.notify("modifying suggestion: \n" .. vim.inspect(suggestion))
				return suggestion
			end)
		end
	end
end

local blink_config = {
	signature = { enabled = true },

	keymap = {
		-- See :h blink-cmp-config-keymap for defining your own keymap
		preset = "none",

		-- smart toggle_menu
		["<C-.>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					-- vim.notify("menu is visible, close it:\n" .. vim.inspect(cmp))
					cmp.hide()
				else
					-- vim.notify("menu is not visible, open it:\n" .. vim.inspect(cmp))
					cmp.show()
				end
			end,
		},

		-- cancel copilot suggestion if it is visible, or dothing
		["<C-/>"] = {
			function()
				if cs.is_visible() then
					-- vim.notify("copilot suggestion is visible, cancel it")
					cs.dismiss()
				end

				return true -- prevent insert '/'
			end,
		},

		["<Tab>"] = {
			super_tab_entry,
			"snippet_forward",
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					cmp.select_prev()
					return true
				end

				if cs.is_visible() then
					cs.prev()
					return true
				end
			end,
			-- "select_prev",
			"fallback_to_mappings",
		},
		["<C-n>"] = {
			function(cmp)
				if cmp.is_menu_visible() then
					cmp.select_next()
					return true
				end

				if cs.is_visible() then
					cs.next()
					return true
				end
			end,
			-- "select_next",
			"fallback_to_mappings",
		},

		["<C-k>"] = {
			--"show",
			"show_documentation",
			"hide_documentation",
		},
	},

	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		nerd_font_variant = "mono",
	},
	completion = {

		-- (Default) Only show the documentation popup when manually triggered
		documentation = { auto_show = false },

		menu = {
			draw = {
				components = {
					kind_icon = {
						text = function(ctx)
							local icon = ctx.kind_icon
							if vim.tbl_contains({ "Path" }, ctx.source_name) then
								local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
								if dev_icon then icon = dev_icon end
							else
								icon = require("lspkind").symbolic(ctx.kind, {
									mode = "symbol",
								})
							end
							return icon .. ctx.icon_gap
						end,
					},
				},
				padding = { 0, 1 },
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", gap = 1, "kind" },
				},
			},
		},
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
}
require("blink.cmp").setup(blink_config)
