-- stylua: ignore start
local ts_langs = {
	-- "latex", -- cause parsing markdown embed latex equation failed
	"regex", "vimdoc", "bash", "c", "cpp", "css", "go", "gomod",
	"html", "javascript", "json", "lua", "make", "python",
	"markdown_inline", "markdown", "rust", "typescript", "yaml",
	"nickel", "nix", "scheme", "elvish", "purescript",
}
-- stylua: ignore end

local config = {
	ensure_installed = ts_langs,
	highlight = {
		enable = true,
		disable = function(ft, bufnr)
			local maxLines = 10000
			if vim.tbl_contains({ "gitcommit" }, ft) or (vim.api.nvim_buf_line_count(bufnr) > maxLines and ft ~= "vimdoc") then return true end

			local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
			return ok and is_large_file
		end,
		additional_vim_regex_highlighting = false,
	},
}
config.textobjects = {
	swap = {
		enable = true,
		swap_next = {
			[",pn"] = "@parameter.inner",
		},
		swap_previous = {
			[",pp"] = "@parameter.inner",
		},
	},
	move = {
		enable = true,
		set_jumps = true,
		-- Object "start" for previous siblings and/or its descendant, or ancestors.
		goto_previous_start = {
			["[f"] = "@function.outer",
			["[F"] = "@function.inner",
			-- ["[z"] = { query = "@fold", query_group = "folds", desc = "previous fold" },
		},
		-- Object "end" for following siblings and/or its descendant, or ancestors.
		-- This is symmetric to goto_previous_start.
		goto_next_end = {
			["]f"] = "@function.outer",
			["]F"] = "@function.inner",
		},

		-- Object "end" for previous siblings and/or its descendant, or ancestors.
		-- The "end" of previous siblings is quite confusing, so it is virtually useless.
		goto_previous_end = {},

		-- Ojbect "end"
		goto_next_start = {
			["]nf"] = "@function.outer",
			["]nF"] = "@function.inner",
			-- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
		},
	},
	select = {
		enable = true,

		-- Automatically jump forward to textobj, similar to targets.vim
		lookahead = true,

		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			["aF"] = "@function.outer",
			["iF"] = "@function.inner",
			["af"] = "@call.outer",
			["if"] = "@call.inner",
			["ap"] = "@parameter.outer",
			["ip"] = "@parameter.inner",
			-- You can also use captures from other query groups like `locals.scm`
			["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
			["ac"] = "@comment.outer", -- only support one line (include line following content)

			-- ["ac"] = "@class.outer",
			-- You can optionally set descriptions to the mappings (used in the desc parameter of
			-- nvim_buf_set_keymap) which plugins like which-key display
			-- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
		},

		-- You can choose the select mode (default is charwise 'v')
		--
		-- Can also be a function which gets passed a table with the keys
		-- * query_string: eg '@function.inner'
		-- * method: eg 'v' or 'o'
		-- and should return the mode ('v', 'V', or '<c-v>') or a table
		-- mapping query_strings to modes.
		selection_modes = {
			-- ["@parameter.outer"] = "v", -- force select "parameter" as charwise
			-- ["@function.outer"] = "V", -- force select whole "function" as linewise
		},
		-- selection_modes = function(sel)
		-- 	-- local query_string = sel.query_string
		-- 	-- vim.notify(vim.inspect(vim.fn.mode()))
		-- 	-- vim.notify(("query_string: %s, method: %s"):format(query_string, sel.method))
		-- 	-- return "v"
		-- end,

		-- If you set this to `true` (default is `false`) then any textobject is
		-- extended to include preceding or succeeding whitespace. Succeeding
		-- whitespace has priority in order to act similarly to eg the built-in
		-- `ap`.
		--
		-- Can also be a function which gets passed a table with the keys
		-- * query_string: eg '@function.inner'
		-- * selection_mode: eg 'v'
		-- and should return true or false
		include_surrounding_whitespace = false,
	},
	matchup = { enable = true },
}

require("nvim-treesitter.install").prefer_git = true
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup(config)

require("nvim-ts-autotag").setup() -- Use treesitter to autoclose and autorename html tag
require("mini.pairs").setup() -- autoclose pairs

require("mini.comment").setup({
	-- notice that `,` key must be configured in **mini.clue**
	mappings = {
		-- Toggle comment (like `,/ip` - comment inner paragraph) for both
		-- Normal and Visual modes
		comment = ",/",

		-- Toggle comment on current line
		comment_line = ",/",

		-- Toggle comment on visual selection
		comment_visual = ",/",

		-- Define 'comment' textobject (like `d,/` - delete whole comment block)
		-- Works also in Visual mode if mapping differs from `comment_visual`
		textobject = ",/",
	},
})
require("mini.surround").setup({
	n_lines = 200,
})
-- press `sh?`(? is any key) to show surround range
vim.api.nvim_set_hl(0, "MiniSurround", {
	bg = "red",
	fg = "white",
	underline = true,
	bold = true,
})

local miniai = require("mini.ai")
miniai.setup({
	n_lint = 500,
	custom_textobjects = {
		g = function()
			local from = { line = 1, col = 1 }
			local to = {
				line = vim.fn.line("$"),
				col = math.max(vim.fn.getline("$"):len(), 1),
			}
			return { from = from, to = to }
		end,

		-- -- mini.ai "@function.inner" didn't work as expected and
		-- -- was replaced with nvim.treesitter-textobjects instead.
		-- F = miniai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),

		o = miniai.gen_spec.treesitter({
			a = { "@conditional.outer", "@loop.outer" },
			i = { "@conditional.inner", "@loop.inner" },
		}),
	},
})

require("wildfire").setup() -- treesitter based incremental and decremental selection

require("mini.move").setup({
	mappings = {
		left = "<S-h>", -- "H"
		right = "<S-l>", -- "L"
		down = "<S-j>", -- "J"
		up = "<S-k>", -- "K"
	},
})

-------------------- goto block outer --------------------

require("treesitter-outer").setup({
	-- -- g[, g[ has bound to surround, but I don't employ them.
	prev_outer_key = "g[", -- "g<",
	next_outer_key = "g]", -- "g>",
})

-- split or join parameters into/from multilines
require("mini.splitjoin").setup({
	mappings = {
		toggle = ",s",
	},
})

---------------------- matchup matchparen tips ------------------------

vim.g.matchup_matchparen_offscreen = { method = "popup" }
vim.api.nvim_set_hl(0, "MatchParen", {
	bg = "white",
	fg = "blue",
	italic = true,
})
