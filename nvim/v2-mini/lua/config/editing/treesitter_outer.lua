-- Jump to the start/end of the outermost treesitter node surrounding the
-- cursor. Query files live in queries/<lang>/treesitter-outer.scm.

local M = {}

local function does_surround(a, b)
	local a_start_row, a_start_col, a_end_row, a_end_col = a[1], a[2], a[3], a[4]
	local b_start_row, b_start_col, b_end_row, b_end_col = b[1], b[2], b[3], b[4]

	if a_start_row < b_start_row and a_end_row > b_end_row then
		return true
	end

	if a_start_row == b_start_row and b_end_row == a_end_row then
		return b_start_col > a_start_col and b_end_col < a_end_col
	end

	if a_start_row == b_start_row then
		return b_start_col > a_start_col
	end

	if a_end_row == b_end_row then
		return b_end_col < a_end_col
	end

	return false
end

local function normalize_selection(sel_start, sel_end)
	local _, sel_start_row, sel_start_col = unpack(sel_start)
	local start_max_cols = #vim.fn.getline(sel_start_row)
	-- visual line mode results in getpos("'>") returning a massive number so
	-- we have to set it to the true end col
	if start_max_cols < sel_start_col then
		sel_start_col = start_max_cols
	end
	-- tree-sitter uses zero-indexed rows
	sel_start_row = sel_start_row - 1
	-- tree-sitter uses zero-indexed cols for the start
	sel_start_col = sel_start_col - 1

	local _, sel_end_row, sel_end_col = unpack(sel_end)
	local end_max_cols = #vim.fn.getline(sel_end_row)
	-- visual line mode results in getpos("'>") returning a massive number so
	-- we have to set it to the true end col
	if end_max_cols < sel_end_col then
		sel_end_col = end_max_cols
	end
	-- tree-sitter uses zero-indexed rows
	sel_end_row = sel_end_row - 1

	return { sel_start_row, sel_start_col, sel_end_row, sel_end_col }
end

function M.outer(is_start)
	local bufnr = vim.api.nvim_get_current_buf()
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then return end
	local lang = parser:lang()
	local query = vim.treesitter.query.get(lang, "treesitter-outer")
	if not query then return end
	local tree = parser:parse()[1]
	if not tree then return end
	local root = tree:root()

	-- treesitter-outer queries use #make-range! "range" @_start @_end to
	-- define ranges. In nvim 0.12's iter_matches, #make-range! does not
	-- populate metadata, so we rebuild each range by pairing @_start (take
	-- start position of first node) with @_end (take end position of last
	-- node) within each match.
	local start_id, end_id
	for cid, name in ipairs(query.captures) do
		if name == "_start" then start_id = cid end
		if name == "_end" then end_id = cid end
	end
	if not start_id or not end_id then return end

	local sel = normalize_selection(vim.fn.getpos("."), vim.fn.getpos("."))
	local max = { 0, 0 }
	for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
		local sn = match[start_id]
		local en = match[end_id]
		if sn and en then
			-- match[cid] is a list of TSNode (nvim 0.11+); handle both list
			-- and single-node shapes defensively.
			local start_node = type(sn) == "table" and sn[1] or sn
			local end_list = type(en) == "table" and en or { en }
			local end_node = end_list[#end_list]

			local sr, sc = start_node:range()
			local _, _, er, ec = end_node:range()
			local match_range = { sr, sc, er, ec }
			if does_surround(match_range, sel) then
				if match_range[1] > max[1] or (match_range[1] == max[1] and match_range[2] > max[2]) then
					max = match_range
				end
			end
		end
	end

	if #max > 2 then
		if is_start then
			vim.api.nvim_win_set_cursor(0, { max[1] + 1, max[2] })
		else
			vim.api.nvim_win_set_cursor(0, { max[3] + 1, max[4] })
		end
	end
end

M.config = {
	filetypes = {
		"c",
		"cpp",
		"elixir",
		"fennel",
		"foam",
		"go",
		"javascript",
		"julia",
		"lua",
		"nix",
		"php",
		"python",
		"r",
		"ruby",
		"rust",
		"scss",
		"tsx",
		"typescript",
	},
	mode = { "n", "v" },
	prev_outer_key = "[{",
	next_outer_key = "]}",
}

local get_default_config = function()
	return M.config
end

M.setup = function(opt)
	opt = opt or {}
	M.config = vim.tbl_deep_extend("force", get_default_config(), opt)

	local function set_buf_keymaps(bufnr)
		vim.keymap.set(M.config.mode, M.config.prev_outer_key, function() M.outer(true) end,
			{ noremap = true, silent = true, buffer = bufnr, desc = "Jump to start position of outer node" })
		vim.keymap.set(M.config.mode, M.config.next_outer_key, function() M.outer(false) end,
			{ noremap = true, silent = true, buffer = bufnr, desc = "Jump to end position of outer node" })
	end

	local group = vim.api.nvim_create_augroup("TreesitterOuter", { clear = true })
	vim.api.nvim_create_autocmd(
		{ "Filetype" },
		{
			pattern = M.config.filetypes,
			callback = function(args) set_buf_keymaps(args.buf) end,
			group = group,
		}
	)

	-- Apply to already-open buffers whose filetype matches. This handles the
	-- case where buffers were opened before setup() ran (e.g. `nvim file.lua`
	-- sets filetype before later() blocks execute, so the FileType autocmd
	-- above misses them). Without this, g[/g] fall through to mini.surround's
	-- global mapping with the same keys.
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.tbl_contains(M.config.filetypes, vim.bo[bufnr].filetype) then
			set_buf_keymaps(bufnr)
		end
	end
end

return M
