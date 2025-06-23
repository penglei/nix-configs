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
