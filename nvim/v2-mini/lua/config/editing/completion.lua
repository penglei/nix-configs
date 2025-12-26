-- Do not hide AI suggestions when the cmp menu is displayed. Keep both visible simultaneously to enable automatic updates of Copilot suggestions
-- after switching cmp candidates, i.e., generate new suggestions based on the newly selected candidate.
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

local function make_config(ai_virtext_sugg)
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
		local ai_visible = ai_virtext_sugg.enabled and ai_virtext_sugg.is_visible()

		-- Debug logging (uncomment to diagnose issues)
		-- vim.notify(string.format("Tab: snippet=%s, menu=%s, ai=%s",
		-- 	tostring(snippet_active), tostring(menu_visible), tostring(ai_visible)))

		if snippet_active then
			-- If menu is visible while in snippet
			if menu_visible then
				-- Check if the selected item has actual snippet placeholders
				local selected_item = cmp.get_selected_item()
				local has_placeholders = has_snippet_placeholders(selected_item)
				-- vim.notify(string.format("  selected_item has_placeholders=%s, label=%s",
				-- 	tostring(has_placeholders),
				-- 	selected_item and selected_item.label or "nil"))
				if has_placeholders then
					-- Only stop snippet session if accepting another snippet
					-- to prevent extmark corruption
					vim.snippet.stop()
				end
				-- Accept the completion; if it's not a snippet, snippet session remains active
				return cmp.select_and_accept()
			end

			-- AI suggestion visible while in snippet: stop snippet first to prevent
			-- extmark corruption, then accept AI suggestion
			if ai_visible then
				vim.snippet.stop()
				ai_virtext_sugg.accept()
				return true
			end

			-- No menu, no AI suggestion visible, let fallback handle snippet_forward
			return false
		else
			-- select in menu
			if menu_visible then
				-- Dismiss AI suggestion before accepting menu item to avoid conflicts
				-- when the accepted item is a snippet
				if ai_visible then
					ai_virtext_sugg.dismiss()
				end

				if tab_as_next then
					return cmp.select_next()
				else
					return cmp.select_and_accept()
				end
			else
				-- No menu visible, try to accept AI suggestion
				if ai_visible then
					ai_virtext_sugg.accept()
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
						-- vim.notify("menu is visible, close it:\n" .. vim.inspect(cmp))
						cmp.hide()
					else
						-- vim.notify("menu is not visible, open it:\n" .. vim.inspect(cmp))
						cmp.show()
					end
				end,
			},

			-- cancel ai suggestion if it is visible, or dothing
			["<C-/>"] = {
				function()
					if ai_virtext_sugg.is_visible() then
						-- vim.notify("ai suggestion is visible, cancel it")
						ai_virtext_sugg.dismiss()
					end

					return true -- prevent fallback to default and insert '/'
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
			["<C-p>"] = {
				function(cmp)
					--- Prioritize the page-turning selection of virtualtext.
					if ai_virtext_sugg.is_visible() then
						ai_virtext_sugg.prev()
						return true
					end

					if cmp.is_menu_visible() then
						cmp.select_prev()
						return true
					end
				end,
				-- "select_prev",
				"fallback_to_mappings",
			},
			["<C-n>"] = {
				function(cmp)
					--- Prioritize the page-turning selection of virtualtext.
					if ai_virtext_sugg.is_visible() then
						ai_virtext_sugg.next()
						return true
					end

					if cmp.is_menu_visible() then
						cmp.select_next()
						return true
					end
				end,
				-- "select_next",
				"fallback_to_mappings",
			},

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
									if ctx.source_name == "supermaven" then
										icon = ""
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end
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
				-- "supermaven", -- ai
			},
			-- default = { "lsp", "buffer", "codecompanion", "snippets", "path" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					-- make lazydev completions top priority (see `:h blink.cmp`)
					score_offset = 100,
				},
				supermaven = {
					name = "supermaven",
					module = "blink.compat.source",
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
	setup = function(config)
		if config == nil then config = {} end

		local blink_config = make_config(config.ai_virtext_sugg)
		require("blink.cmp").setup(blink_config)
	end,
}
