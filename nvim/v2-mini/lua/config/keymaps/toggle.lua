-- Create some toggle mappings
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")

Snacks.toggle
	.new({
		id = "lsp_line_virtext",
		name = "Lsp Line Virtual Text",
		get = function() return vim.diagnostic.config().virtual_lines end,
		set = function(state) vim.diagnostic.config({ virtual_lines = state }) end,
	})
	:map("<leader>ue")
-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	pattern = "*",
-- 	callback = function() vim.diagnostic.config({ virtual_lines = { current_line = true } }) end,
-- 	desc = "Enable virtual_lines with current_line",
-- })
--
-- vim.api.nvim_create_autocmd("CursorMoved", {
-- 	pattern = "*",
-- 	callback = function() vim.diagnostic.config({ virtual_lines = false }) end,
-- 	desc = "Disable virtual_lines",
-- })

local summary_panel_state = false
Snacks.toggle
	.new({
		id = "neotest_summary_panel",
		name = "Neotest Summary Panel",
		get = function() return summary_panel_state end,
		set = function(state)
			vim.api.nvim_command("ToggleNeotestSummar")
			summary_panel_state = state
		end,
	})
	:map("<leader>ut")
-- ["n|<leader>ut"] = map_cr("ToggleNeotestSummar"):desc("Toogle test summary panel"),

local markview_state = true
Snacks.toggle
	.new({
		id = "markview_all",
		name = "Markview(all)",
		get = function() return markview_state end,
		set = function(state)
			vim.api.nvim_cmd({ cmd = "Markview", args = { "toggleAll" } }, { output = false })
			markview_state = state
		end,
	})
	:map("<leader>uv")

Snacks.toggle
	.new({
		id = "render_image",
		name = "Render Image",
		get = function()
			local snacks_image_doc = require("snacks.image.doc")
			return snacks_image_doc.state
		end,
		set = function(state)
			local snacks_image_doc = require("snacks.image.doc")
			if state then
				snacks_image_doc.enable()
			else
				snacks_image_doc.disable()
			end
		end,
	})
	:map("<leader>ui")
