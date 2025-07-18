---============= cmdline, input, search, ===============
--- deprecated:
---   cmdline: enhanced by blink.cmp
---   input: Snacks.Input
---   search: needn't to show candidates in a popup menu.

------------------------ wilder ------------------------

local function setup_wilder()
	vim.api.nvim_set_keymap("c", "<C-p>", "<Up>", { noremap = true })
	vim.api.nvim_set_keymap("c", "<C-n>", "<Down>", { noremap = true })

	local wilder = require("wilder")
	wilder.setup({
		modes = { ":", "/", "?" },
		next = "<C-N>",
	})
	wilder.set_option("pipeline", {
		wilder.branch(
			wilder.python_file_finder_pipeline({
				-- file_command = { "find", ".", "-type", "f", "-printf", "%P\n" },
				file_command = { "rg", "--files" },

				-- dir_command = { "find", ".", "-type", "d", "-printf", "%P\n" },
				dir_command = { "fd", "-td" },

				-- use {'cpsm_filter'} for performance, requires cpsm vim plugin
				-- found at https://github.com/nixprime/cpsm
				filters = { "fuzzy_filter", "difflib_sorter" },
			}),
			wilder.cmdline_pipeline({
				fuzzy = 1,
				set_pcre2_pattern = 1,
			}),
			wilder.python_search_pipeline({ pattern = "fuzzy" })
		),
	})

	-- stylua: ignore start
	local gradient = {
		"#f4468f", "#fd4a85", "#ff507a", "#ff566f", "#ff5e63", "#ff6658",
		"#ff704e", "#ff7a45", "#ff843d", "#ff9036", "#f89b31", "#efa72f",
		"#e6b32e", "#dcbe30", "#d2c934", "#c8d43a", "#bfde43", "#b6e84e", "#aff05b",
	}
	-- stylua: ignore end

	for i, fg in ipairs(gradient) do
		gradient[i] = wilder.make_hl("WilderGradient" .. i, "Pmenu", { { a = 1 }, { a = 1 }, { foreground = fg } })
	end
	wilder.set_option(
		"renderer",
		wilder.renderer_mux({
			[":"] = wilder.popupmenu_renderer({
				highlights = {
					gradient = gradient,
				},
				highlighter = wilder.highlighter_with_gradient({
					wilder.basic_highlighter(),
				}),
				left = { " ", wilder.popupmenu_devicons() },
				right = { " ", wilder.popupmenu_scrollbar() },
			}),
			["/"] = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
				highlighter = {
					wilder.pcre2_highlighter(),
					wilder.basic_highlighter(),
				},
				highlights = {
					border = "Normal", -- highlight to use for the border
					accent = wilder.make_hl("WilderAccent", "Pmenu", {
						{ a = 1 },
						{ a = 1 },
						{ foreground = "#f4468f" },
					}),
				},
				left = { " ", wilder.popupmenu_devicons() },
				right = { " ", wilder.popupmenu_scrollbar() },
				-- 'single', 'double', 'rounded' or 'solid'
				-- can also be a list of 8 characters, see :h wilder#popupmenu_border_theme() for more details
				border = "rounded",
			})),
		})
	)
end

--------------------------- noice ----------------------------

---@diagnostic disable-next-line: unused-function
local function setup_noice()
	local util = require("config.util")
	local pos = util.win.calsize(0, 1)

	local command_line_popup = {
		presets = {
			command_palette = true,
		},
		cmdline = {
			view = "cmdline_popup",
		},
		views = {
			cmdline_popup = {
				position = {
					row = pos.height - 3,
					col = "50%",
				},
				size = {
					width = 60,
					height = 1,
				},
			},
			cmdline_popupmenu = {
				position = {
					row = pos.height - 6,
					col = "50%",
				},
				size = { width = 60, height = "auto", max_height = 33 },
			},
		},
	}
	local noice_config = {
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			-- command_palette = false, -- position the cmdline and popupmenu together
			-- long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = true, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
		cmdline = {
			enabled = false,
			view = "cmdline",
		},

		-- record all notifications into internal cache, so they can be revisited by a picker.
		-- it hijacks vim.notify internally.
		notify = {
			enabled = true,
		},

		lsp = {
			progress = {
				enabled = false, -- has shown in notification
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
	}

	---@diagnostic disable-next-line: unused-local
	local noice_popup_style_config = vim.tbl_deep_extend("force", noice_config, command_line_popup)

	---@diagnostic disable-next-line: missing-fields
	require("noice").setup(noice_config)
end

setup_wilder()
