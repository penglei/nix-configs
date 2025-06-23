-- stylua: ignore start
local langs = {
	-- "latex", -- cause parsing markdown embed latex equation failed
	"regex", "vimdoc", "bash", "c", "cpp", "css", "go", "gomod",
	"html", "javascript", "json", "lua", "make", "python",
	"markdown_inline", "markdown", "rust", "typescript", "yaml",
	"nickel", "nix", "scheme", "elvish", "purescript",
}
-- stylua: ignore end

local textobjects = {
	swap = {
		enable = true,
		swap_next = {
			[",pn"] = "@parameter.inner",
		},
		swap_previous = {
			[",pp"] = "@parameter.inner",
		},
	},
	select = {
		enable = true,

		-- Automatically jump forward to textobj, similar to targets.vim
		lookahead = true,

		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ap"] = "@parameter.outer",
			["ip"] = "@parameter.inner",
			-- You can also use captures from other query groups like `locals.scm`
			["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },

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
			["@parameter.outer"] = "v", -- charwise
			["@function.outer"] = "V", -- linewise
			["@class.outer"] = "<c-v>", -- blockwise
		},
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
	move = {
		enable = true,
		set_jumps = true,
		-- Object "start" for previous siblings and/or its descendant, or ancestors.
		goto_previous_start = {
			["[f"] = "@function.outer",
			["[F"] = "@function.inner",
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
		},
	},
	-- matchup = { enable = true },
}

local config = {
	ensure_installed = langs,
	textobjects = textobjects,
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
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup(config)
require("nvim-ts-autotag").setup()

require("nvim-treesitter.install").prefer_git = true
