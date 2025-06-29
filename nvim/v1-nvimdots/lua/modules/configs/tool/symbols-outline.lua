return function()
	-- Error detected while processing function clever_f#find_with[97]..function clever_f#find_with[44]..<SNR>126_getchar[2]..CursorHold Autocommands for "*":
	-- Error executing lua callback: ...lazy/symbols-outline.nvim/lua/symbols-outline/writer.lua:21:
	-- E565: Not allowed to change text or change window
	-- stack traceback:[C]:
	--  in function 'nvim_buf_set_lines'^@^I...lazy/symbols-outline.nvim/lua/symbols-outline/writer.lua:21:
	--  in function 'write_outline'^@^I...lazy/symbols-outline.nvim/lua/symbols-outline/writer.lua:92:
	--  in function 'parse_and_write'^@^I...e/nvim/lazy/symbols-outline.nvim/lua/symbols-outline.lua:71:
	--  in function '_update_lines'^@^I...e/nvim/lazy/symbols-outline.nvim/lua/symbols-outline.lua:203:
	--  in function '_highlight_current_item'^@^I...e/nvim/lazy/symbols-outline.nvim/lua/symbols-outline.lua:19:
	--  in function <...e/nvim/lazy/symbols-outline.nvim/lua/symbols-outline.lua:18>

	require("symbols-outline").setup({
		highlight_hovered_item = false,
		auto_unfold_hover = false,
	})
end
