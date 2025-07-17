local mk = require("mini.keymap")
local notify_many_keys = function(key)
	local lhs = string.rep(key, 18)
	local action = function() vim.notify("Too many " .. key .. "!") end
	mk.map_combo({ "n", "x" }, lhs, action)
end
notify_many_keys("h")
notify_many_keys("j")
notify_many_keys("k")
notify_many_keys("l")

local mode = { "i", "c", "s" }
mk.map_combo(mode, "jj", "<BS><BS><Esc>j")
mk.map_combo(mode, "jk", "<BS><BS><Esc>k")
-- To not have to worry about the order of keys, also map "kj"
mk.map_combo(mode, "kj", "<BS><BS><Esc>k")

-- Escape into Normal mode from Terminal mode
mk.map_combo("t", "jk", "<BS><BS><C-\\><C-n>")
mk.map_combo("t", "kj", "<BS><BS><C-\\><C-n>")
vim.keymap.set("n", "v", "mvv", { noremap = true })
vim.keymap.set("n", "gb", function() require("snipe").open_buffer_menu() end, { noremap = true, desc = "Open Snipe buffer menu" })

--  This doesn't ask for confirmation and just increase all the headings
vim.keymap.set("n", ",hI", function()
	-- Save the current cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- I'm using [[ ]] to escape the special characters in a command
	vim.cmd([[:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/]])
	-- Restore the cursor position
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- Clear search highlight
	vim.cmd("nohlsearch")
end, { desc = "[P]Increase headings without confirmation" })

vim.keymap.set("n", ",hD", function()
	-- Save the current cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- I'm using [[ ]] to escape the special characters in a command
	vim.cmd([[:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/]])
	-- Restore the cursor position
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- Clear search highlight
	vim.cmd("nohlsearch")
end, { desc = "[P]Decrease headings without confirmation" })

-- Increase markdown headings for text selected in visual mode
vim.keymap.set("v", ",hI", function()
	-- Save cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- Get visual selection bounds and ensure correct order
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	local buf = vim.api.nvim_get_current_buf()
	-- Process each line in the selection
	for lnum = start_line, end_line do
		local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
		if line and line:match("^##+%s") then -- Match headings level 2+
			local new_line = "#" .. line
			vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { new_line })
		end
	end
	-- Restore cursor and clear highlights
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	vim.cmd("nohlsearch")
end, { desc = "Increase headings in visual selection" })

-- Decrease markdown headings for text selected in visual mode
vim.keymap.set("v", ",hD", function()
	-- Save cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- Get visual selection bounds and ensure correct order
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	local buf = vim.api.nvim_get_current_buf()
	-- Process each line in the selection
	for lnum = start_line, end_line do
		local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
		if line and line:match("^##+%s") then -- Match headings level 2+
			-- Split into hashes and content, then remove one #
			local hashes, content = line:match("^(#+)(%s.+)$")
			if hashes and #hashes >= 2 then
				local new_hashes = hashes:sub(1, #hashes - 1)
				local new_line = new_hashes .. content
				vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { new_line })
			end
		end
	end
	-- Restore cursor and clear highlights
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	vim.cmd("nohlsearch")
end, { desc = "Decrease headings in visual selection" })
