local function make_config()
	local tab_as_next = false

	-- Helper function to check if a completion item contains actual snippet placeholders
	-- Many LSPs mark items as snippet format even when they don't have placeholders
	local function has_snippet_placeholders(item)
		if not item then return false end
		if item.insertTextFormat ~= vim.lsp.protocol.InsertTextFormat.Snippet then
			return false
		end

		-- Get the text that will be inserted
		local insert_text = item.insertText
		if not insert_text and item.textEdit then
			insert_text = item.textEdit.newText
		end
		if not insert_text then
			insert_text = item.label
		end

		if not insert_text then return false end

		-- Check for snippet placeholder patterns: $1, ${1}, ${1:default}, $0
		-- Simple pattern check for common snippet syntax
		return insert_text:match("%$%d") ~= nil or insert_text:match("%${%d") ~= nil
	end

	---@diagnostic disable-next-line: unused-function
	local super_tab_entry = function(cmp)
		local snippet_active = cmp.snippet_active()
		local menu_visible = cmp.is_menu_visible()

		if snippet_active then
			if menu_visible then
				-- Check if the selected item has actual snippet placeholders
				local selected_item = cmp.get_selected_item()
				local has_placeholders = has_snippet_placeholders(selected_item)
				if has_placeholders then
					-- Only stop snippet session if accepting another snippet
					-- to prevent extmark corruption
					vim.snippet.stop()
				end
				-- Accept the completion; if it's not a snippet, snippet session remains active
				return cmp.select_and_accept()
			end

			-- No menu, let fallback handle snippet_forward
			return false
		else
			-- select in menu
			if menu_visible then
				if tab_as_next then
					return cmp.select_next()
				else
					return cmp.select_and_accept()
				end
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
						cmp.hide()
					else
						cmp.show()
					end
				end,
			},

			["<Tab>"] = {
				super_tab_entry,
				"snippet_forward",
				"fallback",
			},
			["<S-Tab>"] = {
				function(cmp)
					if cmp.is_menu_visible() then
						if tab_as_next then return cmp.select_prev() end
					end
				end,
				-- "select_prev", -- if tab_as_next
				"snippet_backward",
				"fallback",
			},
			-- ["<CR>"] = {
			-- 	-- function(cmp)
			-- 	-- 	if cmp.is_menu_visible() then return cmp.select_and_accept() end
			-- 	-- end,
			-- 	"select_and_accept",
			-- 	"fallback",
			-- },
			["<C-y>"] = { "select_and_accept" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback_to_mappings" },
			["<C-n>"] = { "select_next", "fallback_to_mappings" },

			["<C-k>"] = {
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
			default = {
				"lsp",
				"path",
				"snippets",
				"buffer",
				-- "lazydev",
			},
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
			enabled = true, -- wilder is a better choice?
			sources = { "cmdline", "path" },
			keymap = { preset = "inherit" },
			completion = { ghost_text = { enabled = true }, menu = { auto_show = true } },
		},
	}

	return blink_config
end

return {
	setup = function()
		require("blink.cmp").setup(make_config())
	end,
}
