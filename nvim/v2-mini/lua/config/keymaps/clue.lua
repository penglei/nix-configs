local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- ',' key
		{ mode = "n", keys = "," },
		{ mode = "x", keys = "," },

		-- '[' and ']' keys
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "x", keys = "[" },
		{ mode = "x", keys = "]" },

		{ mode = "x", keys = "a" },
		{ mode = "x", keys = "i" },

		-- 's' for surround
		{ mode = "n", keys = "s" },
		{ mode = "x", keys = "s" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },

		-- Match and marks
		{ mode = "n", keys = "m" },
		{ mode = "x", keys = "m" },
	},

	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
	window = {
		width = 50,
		delay = 120,
	},
})
