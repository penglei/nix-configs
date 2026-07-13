-- stylua: ignore start
local ts_langs = {
	"regex", "vimdoc", "bash", "c", "cpp", "css", "go", "gomod",
	"html", "javascript", "json", "lua", "make", "python",
	"markdown", "markdown_inline", "rust", "typescript", "yaml",
	"nickel", "nix", "scheme", "elvish", "purescript",
	"latex", "scss", "svelte", "tsx", "typst", "vue",
	"ocaml", "ocaml_interface", "agda", "julia", "sql",
}
-- stylua: ignore end

-- nvim-treesitter `main` branch (nvim 0.12+): minimal — only parser install
-- + query distribution. Highlighting is started per-buffer via core
-- `vim.treesitter.start()`; textobjects/matchup modules are gone and
-- configured on their own plugins below.
require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- ensure_installed → install() (async; no-op if already installed)
require("nvim-treesitter").install(ts_langs)

-- highlight: FileType autocmd replacing the old `highlight = { enable, disable }` module.
local max_lines = 10000
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft, bufnr = args.match, args.buf
		if ft == "gitcommit" then return end
		if vim.api.nvim_buf_line_count(bufnr) > max_lines and ft ~= "vimdoc" then return end
		local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
		if ok and is_large_file then return end
		pcall(vim.treesitter.start)
	end,
})

-- nvim-treesitter-textobjects `main` branch: standalone (no nvim-treesitter
-- module dep). setup() takes only select/move options; keymaps are manual.
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {},
		include_surrounding_whitespace = false,
	},
	move = { set_jumps = true },
})
local tso_select = require("nvim-treesitter-textobjects.select")
local tso_swap = require("nvim-treesitter-textobjects.swap")
local tso_move = require("nvim-treesitter-textobjects.move")

-- select keymaps (was: select.keymaps = {...})
vim.keymap.set({ "x", "o" }, "aF", function() tso_select.select_textobject("@function.outer", "textobjects") end, { desc = "Select around function" })
vim.keymap.set({ "x", "o" }, "iF", function() tso_select.select_textobject("@function.inner", "textobjects") end, { desc = "Select inside function" })
vim.keymap.set({ "x", "o" }, "af", function() tso_select.select_textobject("@call.outer", "textobjects") end, { desc = "Select around call" })
vim.keymap.set({ "x", "o" }, "if", function() tso_select.select_textobject("@call.inner", "textobjects") end, { desc = "Select inside call" })
vim.keymap.set({ "x", "o" }, "ap", function() tso_select.select_textobject("@parameter.outer", "textobjects") end, { desc = "Select around parameter" })
vim.keymap.set({ "x", "o" }, "ip", function() tso_select.select_textobject("@parameter.inner", "textobjects") end, { desc = "Select inside parameter" })
vim.keymap.set({ "x", "o" }, "as", function() tso_select.select_textobject("@local.scope", "locals") end, { desc = "Select language scope" })
vim.keymap.set({ "x", "o" }, "ac", function() tso_select.select_textobject("@comment.outer", "textobjects") end, { desc = "Select around comment" })

-- swap keymaps (was: swap.swap_next / swap_previous)
vim.keymap.set("n", ",pn", function() tso_swap.swap_next("@parameter.inner") end, { desc = "Swap with next parameter" })
vim.keymap.set("n", ",pp", function() tso_swap.swap_previous("@parameter.inner") end, { desc = "Swap with previous parameter" })

-- move keymaps (was: move.goto_previous_start / goto_next_end / goto_next_start)
vim.keymap.set({ "n", "x", "o" }, "[f", function() tso_move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[F", function() tso_move.goto_previous_start("@function.inner", "textobjects") end, { desc = "Previous function inner start" })
vim.keymap.set({ "n", "x", "o" }, "]f", function() tso_move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "]F", function() tso_move.goto_next_end("@function.inner", "textobjects") end, { desc = "Next function inner end" })
vim.keymap.set({ "n", "x", "o" }, "]nf", function() tso_move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]nF", function() tso_move.goto_next_start("@function.inner", "textobjects") end, { desc = "Next function inner start" })

require("nvim-ts-autotag").setup() -- Use treesitter to autoclose and autorename html tag
require("mini.pairs").setup() -- autoclose pairs

-- https://github.com/numToStr/Comment.nvim -- TODO: replace
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

-- treesitter-outer: upstream plugin is dead (last commit 2024-06) and hard-
-- requires removed nvim-treesitter.parsers/query modules. We keep the plugin
-- on runtimepath for its query files (queries/<lang>/treesitter-outer.scm)
-- but use this core-API reimplementation instead of its broken init.lua.
require("config.editing.treesitter_outer").setup({
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
vim.api.nvim_set_hl(0, "MatchParen", { italic = true, bold = true, underline = true })

------------- https://github.com/roobert/tabtree.nvim -----------------
require("tabtree").setup({
	--- tips : try run `:InspectTree` to inpsect all ts nodes.
	key_bindings = {
		previous = "[[",
		next = "]]",
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
