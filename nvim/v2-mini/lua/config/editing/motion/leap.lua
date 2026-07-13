-- https://github.com/ggandor/leap-ast.nvim
--
local api = vim.api

-- Inlined from nvim-treesitter master's ts_utils.lua (removed in main branch).
-- Only substitution: ts.get_node_range → vim.treesitter.get_node_range (core API).
local function get_vim_range(range, bufnr)
	local srow, scol, erow, ecol = unpack(range)
	local ecol_adjusted = ecol == 0 and -1 or ecol - 1
	if ecol_adjusted < 0 and erow > 0 then
		erow = erow - 1
		ecol_adjusted = #vim.fn.getline(erow + 1)
	end
	return srow + 1, scol, erow + 1, ecol_adjusted, bufnr or 0
end

local function update_selection(bufnr, node, selection_mode)
	local srow, scol, erow, ecol = get_vim_range({ vim.treesitter.get_node_range(node) }, bufnr)
	vim.api.nvim_buf_set_mark(bufnr, "<", srow, scol, {})
	vim.api.nvim_buf_set_mark(bufnr, ">", erow, ecol, {})
	local mode = selection_mode == "linewise" and "V"
		or selection_mode == "blockwise" and vim.api.nvim_replace_termcodes("<C-v>", true, true, true)
		or "v"
	vim.cmd("normal! " .. mode .. "gv")
	if vim.api.nvim_get_mode().mode:match("no") then vim.cmd("normal! o") end
end

local function get_ast_nodes()
	local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
	-- Get current TS node.
	local cur_node = vim.treesitter.get_node()
	-- local cur_node = ts_utils.get_node_at_cursor(0)
	if not cur_node then return end
	-- Get parent nodes recursively.
	local nodes = { cur_node }
	local parent = cur_node:parent()
	while parent do
		table.insert(nodes, parent)
		parent = parent:parent()
	end
	-- Create Leap targets from TS nodes.
	local targets = {}
	local startline, startcol, endline, endcol
	for _, node in ipairs(nodes) do
		startline, startcol, endline, endcol = node:range() -- (0,0)
		if startline + 1 >= wininfo.topline then
			local target = { node = node, pos = { startline + 1, startcol + 1 } }
			table.insert(targets, target)
			local target2 = { node = node, pos = { endline + 1, endcol + 1 } }
			table.insert(targets, target2)
		end
	end
	if #targets >= 1 then return targets end
end

local function select_range(target)
	local mode = api.nvim_get_mode().mode
	if not mode:match("n?o") then
		-- Force going back to Normal (implies mode = v | V | ).
		vim.cmd("normal! " .. mode)
	end
	update_selection(0, target.node, mode:match("V") and "linewise" or mode:match("") and "blockwise" or "charwise")
end

local leap = require("leap")
-- https://github.com/ggandor/leap.nvim/issues/110
-- leap object is lazy which construct by setmetatable.
-- so we must init leap before call main method on it,
-- or the opts in calling wouldn't work.
leap.opts.labels = "sfnkhwuygtqpcxzUIOPHJKLNM" -- extra label letters

local function ts_leap()
	local targets = get_ast_nodes()
	leap.leap({
		targets = targets,
		action = api.nvim_get_mode().mode ~= "n" and select_range, -- or jump
		backward = false,
		-- opts = {
		-- 	safe_labels = "sufku", -- in a local scope, we don't need too much label letter.
		-- 	labels = "sfnkhowimuyvrgtaqpcxz",
		-- },
	})
end

vim.api.nvim_create_user_command("TreesitterNodeLeap", ts_leap, {
	desc = "treesitter leap selection",
})

vim.keymap.set("v", "gm", ts_leap, { noremap = true }) -- map_cmd not works, so we do keymap here.
