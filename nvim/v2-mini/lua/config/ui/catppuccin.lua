local init = function(config)
	require("catppuccin").setup(config)
	vim.cmd.colorscheme("catppuccin-frappe")
	-- or vim.api.nvim_cmd({ cmd = "colorscheme", args = { "catppuccin-macchiato" } }, {})
end

local settings = { trans_bg = false }
local clear = {}
init({
	flavour = "mocha",
	background = { light = "latte", dark = "mocha" }, -- latte, frappe, macchiato, mocha
	dim_inactive = {
		enabled = false,
		-- Dim inactive splits/windows/buffers.
		-- NOT recommended if you use old palette (a.k.a., mocha).
		shade = "dark",
		percentage = 0.15,
	},
	transparent_background = settings.trans_bg,
	show_end_of_buffer = false, -- show the '~' characters after the end of buffers
	term_colors = true,
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
	styles = {
		comments = { "italic" },
		functions = { "bold" },
		keywords = { "italic" },
		operators = { "bold" },
		conditionals = { "bold" },
		loops = { "bold" },
		booleans = { "bold", "italic" },
		numbers = {},
		types = {},
		strings = {},
		variables = {},
		properties = {},
	},
	integrations = {
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = { "italic" },
				hints = { "italic" },
				warnings = { "italic" },
				information = { "italic" },
			},
			underlines = {
				errors = { "underline" },
				hints = { "underline" },
				warnings = { "underline" },
				information = { "underline" },
			},
		},
		aerial = false,
		alpha = false,
		barbar = false,
		beacon = false,
		cmp = true,
		coc_nvim = false,
		dap = true,
		dap_ui = true,
		dashboard = false,
		dropbar = { enabled = true, color_mode = true },
		fern = false,
		fidget = true,
		flash = true,
		gitgutter = false,
		gitsigns = true,
		harpoon = false,
		headlines = false,
		hop = true,
		illuminate = true,
		indent_blankline = { enabled = true, colored_indent_levels = false },
		leap = true,
		lightspeed = false,
		lsp_saga = false,
		lsp_trouble = false,
		markdown = true,
		mason = false,
		mini = false,
		navic = { enabled = false },
		neogit = false,
		neotest = false,
		---@diagnostic disable-next-line: assign-type-mismatch
		neotree = { enabled = false, show_root = true, transparent_panel = false },
		noice = true,
		notify = true,
		nvimtree = true,
		overseer = false,
		pounce = false,
		rainbow_delimiters = true,
		sandwich = false,
		semantic_tokens = true,
		symbols_outline = false,
		telekasten = false,
		telescope = { enabled = true, style = "nvchad" },
		treesitter_context = true,
		ts_rainbow = true,
		vim_sneak = false,
		vimwiki = false,
		which_key = false,
	},
	color_overrides = {},
	highlight_overrides = {
		all = function(cp)
			return {
				-- For base configs
				NormalFloat = { fg = cp.text, bg = settings.trans_bg and cp.none or cp.mantle },
				FloatBorder = {
					fg = settings.trans_bg and cp.blue or cp.mantle,
					bg = settings.trans_bg and cp.none or cp.mantle,
				},
				CursorLineNr = { fg = cp.green },

				-- For native lsp configs
				DiagnosticVirtualTextError = { bg = cp.none },
				DiagnosticVirtualTextWarn = { bg = cp.none },
				DiagnosticVirtualTextInfo = { bg = cp.none },
				DiagnosticVirtualTextHint = { bg = cp.none },
				LspInfoBorder = { link = "FloatBorder" },

				-- For indent-blankline
				IblIndent = { fg = cp.surface0 },
				IblScope = { fg = cp.surface2, style = { "bold" } },

				-- For nvim-cmp and wilder.nvim
				Pmenu = { fg = cp.overlay2, bg = settings.trans_bg and cp.none or cp.base },
				PmenuBorder = { fg = cp.surface1, bg = settings.trans_bg and cp.none or cp.base },
				PmenuSel = { bg = cp.green, fg = cp.base },
				CmpItemAbbr = { fg = cp.overlay2 },
				CmpItemAbbrMatch = { fg = cp.blue, style = { "bold" } },
				CmpDoc = { link = "NormalFloat" },
				CmpDocBorder = {
					fg = settings.trans_bg and cp.surface1 or cp.mantle,
					bg = settings.trans_bg and cp.none or cp.mantle,
				},

				-- For fidget
				FidgetTask = { bg = cp.none, fg = cp.surface2 },
				FidgetTitle = { fg = cp.blue, style = { "bold" } },

				-- For nvim-notify
				NotifyBackground = { bg = cp.base },

				-- For nvim-tree
				NvimTreeRootFolder = { fg = cp.pink },
				NvimTreeIndentMarker = { fg = cp.surface2 },

				-- For trouble.nvim
				TroubleNormal = { bg = settings.trans_bg and cp.none or cp.base },
				TroubleNormalNC = { bg = settings.trans_bg and cp.none or cp.base },

				-- For telescope.nvim
				TelescopeMatching = { fg = cp.lavender },
				TelescopeResultsDiffAdd = { fg = cp.green },
				TelescopeResultsDiffChange = { fg = cp.yellow },
				TelescopeResultsDiffDelete = { fg = cp.red },

				-- For glance.nvim
				GlanceWinBarFilename = { fg = cp.subtext1, style = { "bold" } },
				GlanceWinBarFilepath = { fg = cp.subtext0, style = { "italic" } },
				GlanceWinBarTitle = { fg = cp.teal, style = { "bold" } },
				GlanceListCount = { fg = cp.lavender },
				GlanceListFilepath = { link = "Comment" },
				GlanceListFilename = { fg = cp.blue },
				GlanceListMatch = { fg = cp.lavender, style = { "bold" } },
				GlanceFoldIcon = { fg = cp.green },

				-- For nvim-treehopper
				TSNodeKey = {
					fg = cp.peach,
					bg = settings.trans_bg and cp.none or cp.base,
					style = { "bold", "underline" },
				},

				-- For treesitter
				["@keyword.return"] = { fg = cp.pink, style = clear },
				["@error.c"] = { fg = cp.none, style = clear },
				["@error.cpp"] = { fg = cp.none, style = clear },
			}
		end,
	},
})
