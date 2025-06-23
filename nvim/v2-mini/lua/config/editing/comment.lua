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
