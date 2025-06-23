---@diagnostic disable: missing-parameter
---
local util = require("config.util")

local map_cr = util.bind.map_cr
local map_cu = util.bind.map_cu
local map_cmd = util.bind.map_cmd
local map_cb = util.bind.map_callback

-- https://superuser.com/questions/770068/in-vim-how-can-i-remap-tab-without-also-remapping-ctrli
-- 终端中 <C-i> 的键码与 <Tab> 相同，若自定义了 <Tab> 的映射，则会覆盖 <C-i>
vim.keymap.set("n", "<C-i>", "<C-i>", { noremap = true }) -- 确保 <C-i> 不被覆盖

-- Set a global key mapping:  ',' as another leader key,
-- so we map single ',' pressing to nothing to prevent it was consumed and trigger any action.
vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

-- vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
-- mode tips:
-- :h Visual-mode
-- :h Select-mode

-- :h mapmode-x: activated only in visual mode
-- :h mapmode-s: activated only in select mode
-- :h mapmode-v: activated in both visual and select mode
-- o: Operator-pending mode: 先按了操作(e.g.  y(复制),d(删除),c(修改))进入等待范围选择的模式。vim的操作习惯是先输入[操作]，再输入[范围]。

local leap_jump_wins = function() require("leap").leap({ target_windows = require("leap.user").get_focusable_windows() }) end
local leap_jump_buf = function() require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } }) end

-- stylua: ignore start
-- 1. try `,pn` on `foo` or {}
-- 2. try `,pp` on `b` or "2"
(function(foo, b, c)
	foo.v = b .. c
end
)({}, "2", "3")
-- stylua: ignore end

local visual_lower_p = function()
	local reg_text = vim.fn.getreg('"', false)
	local reg_type = vim.fn.getregtype('"')

	vim.api.nvim_paste(reg_text, false, -1)
	vim.fn.setreg('"', reg_text, reg_type)
end

local visual_upper_p = function()
	local reg_text = vim.fn.getreg('"', false)
	vim.api.nvim_paste(reg_text, false, -1)
end

local keymaps = {

	----- visual mode has many object selection key binds -----
	-- a/i[f], a/i[p], as

	-- ["n|,pn"]: swap with previous argument
	-- ["n|,pp"]: swap with next argument

	["n|<leader>e"] = map_cr("NvimTreeFindFile"):desc("nvim-tree: Find file"),
	["n|<leader>y"] = map_cmd("<CMD>lua MiniFiles.open()<CR>"):desc("open mini files navigator"), -- like command 'yazi'
	-- ["n|<leader>y"] = map_cmd("<CMD>lua require('yazi').yazi()<CR>"):desc("open mini files navigator"),

	["n|<leader>f"] = map_cu("Pick files"):desc("Mini: Pick file"),
	["n|<leader>b"] = map_cu("Pick buffers"):desc("Mini: Pick buffer"),
	["n|<leader>c"] = map_cu("Pick commands"):desc("Mini: Pick command"),
	["n|<leader>w"] = map_cu("Pick grep_live"):desc("Mini: Pick grep words"),

	["n|<leader>q"] = map_cu("q"):desc("exit"),
	["n|<leader>x"] = map_cu("Bdelete"):desc("delete current buffer"),
	["n|<Esc><Esc>"] = map_cb(function()
		vim.cmd([[nohl]])
		-- TODO chain more auto action
	end):desc("clean ui to default"),

	-- reverse p and P behaviour in visual mode
	["v|p"] = map_cb(visual_lower_p):desc("paste in visual mode"),
	["v|P"] = map_cb(visual_upper_p):desc("paste and override default register"),

	----------------- command line ----------------------
	["c|<C-p>"] = map_cmd("<Up>"),
	["c|<C-n>"] = map_cmd("<Down>"),

	------------------- terminal ------------------------
	["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]),
	-- ["n|<C-'>"] = map_cmd([[<CMD>lua require("FTerm").toggle()<CR>]]):desc("Terminal: toggle float"),
	-- ["t|<C-'>"] = map_cmd('<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>'):desc("Terminal: toggle float"),
	-- ["i|<C-'>"] = map_cb(function() require("FTerm").toggle() end):desc("Terminal: toggle float"),
	["n|<C-'>"] = map_cr([[execute v:count . "ToggleTerm direction=float"]]):desc("terminal: Toggle float"),
	["i|<C-'>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=float<CR>"):desc("terminal: Toggle float"),
	["t|<C-'>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):desc("terminal: Toggle float"),

	["n|K"] = map_cb(function()
		local api = vim.api
		local hover_win = vim.b.hover_preview
		if hover_win and api.nvim_win_is_valid(hover_win) then
			api.nvim_set_current_win(hover_win)
		else
			require("hover").hover()
		end
	end):desc("hover that supports enter the hover window"),
	["n|gK"] = map_cb(function() require("hover").hover() end):desc("hover.nvim (select)"),
	["n|<C-p>"] = map_cb(function() require("hover").hover_switch("previous") end):desc("hover.nvim (previous source)"),
	["n|<C-n>"] = map_cb(function() require("hover").hover_switch("next") end):desc("hover.nvim (next source)"),
	-- vim.keymap.set( "n", "<C-p>",
	-- 	function() require("hover").hover_switch("previous") end,
	-- 	{ desc = "hover.nvim (previous source)" }
	-- ),
	-- vim.keymap.set( "n", "<C-n>",
	-- 	function() require("hover").hover_switch("next") end,
	-- 	{ desc = "hover.nvim (next source)" }
	-- ),

	----------- leap for motion/selection ---------------
	["n|'w"] = map_cb(leap_jump_wins):desc("leap: jump in all windows"),
	["vn|gw"] = map_cb(leap_jump_buf):desc("leap: jump/select in current window"),
	["n|gm"] = map_cr("TreesitterNodeLeap"):desc("leap treesitter jump/select in local scope"), -- BUG: TODO support visual mode
	["nxo|mm"] = map_cb(function() require("leap.treesitter").select() end):desc("leap: select treesitter ranged text"),
	-- tsht: nvim-treehopper (just for)
	-- -- ["n|gm"] = map_cu("HopWord"):desc("Hop: jump to a word in any window"),
	-- -- ["v|gm"] = map_cb(function() require("hop").hint_words() end):desc("Hop: select range to a word"),
	-- ["no|'s"] = map_cu("lua require('tsht').nodes()"):desc("Treehopper: syntax tree selection"),
	-- 因为's'是surround快捷键的前缀，所以我们需要一种方式快速进入syntax tree selection mode, 而不是等待 vim.opt.timeoutlen
	-- ["no|s<CR>"] = map_cu("lua require('tsht').nodes()"):desc("Treehopper: enter syntax selection quickly"),

	------------- test ------------------
	-- ["n|<C-t>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>t<CR>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>pt"] = map_cr("ToggleNeotestSummar"):desc("Toogle test summary panel"),
	["n|<leader>to"] = map_cr("ShowTestOutput"):desc("Neotest: show cursor test output"),
	["n|<leader>pl"] = map_cb(function() require("lsp_lines").toggle() end):desc("Toggle lsp_lines virtual text"),

	------------ comment -----------------
	-- comment key mapping is configured in config.editing.comment and config.ui.mini.clue
	-- ["n|,/"] -- singline comment toggle
	-- ["v|,/"] -- multiline comment toggle

	-------------- core ----------------
	["x|S"] = map_cmd([[:<C-u>lua MiniSurround.add('visual')<CR>]]):desc("mini visual surround only in visual mode"),
	["vn|gh"] = map_cmd("0"):desc("Goto line start"),
	["vn|gl"] = map_cmd("$"):desc("Goto line end"),
	["vn|ge"] = map_cmd("G"):desc("Goto last line"),
	-- ["n|gg"] -- editor default. go to first line.

	["n|<Tab>"] = map_cr("BufferLineCycleNext"):desc("goto next buffer"),
	["n|<S-Tab>"] = map_cr("BufferLineCyclePrev"):desc("goto prev buffer"),

	["n|Y"] = map_cmd("y$"):desc("editn: Yank text to EOL"),
	["v|Y"] = map_cb(function()
		vim.cmd("normal! y")
		local text = vim.fn.getreg('"', false)
		vim.fn.setreg("*", text)
		vim.notify("Clipboard  updated")
	end):desc("Copy to clipboard (also default register)"),

	["n|D"] = map_cmd("d$"):desc("editn: Delete text to EOL"),
	-- Window motion
	["n|<C-h>"] = map_cmd("<C-w>h"):desc("window: Focus left"),
	["n|<C-l>"] = map_cmd("<C-w>l"):desc("window: Focus right"),
	["n|<C-j>"] = map_cmd("<C-w>j"):desc("window: Focus down"),
	["n|<C-k>"] = map_cmd("<C-w>k"):desc("window: Focus up"),
	-- Insert mode
	["i|<C-u>"] = map_cmd("<C-G>u<C-U>"):desc("editi: Delete previous block"),
	["i|<C-b>"] = map_cmd("<Left>"):desc("editi: Move cursor to left"),
	["i|<C-a>"] = map_cmd("<ESC>^i"):desc("editi: Move cursor to line start"),
	-- Command mode
	["c|<C-b>"] = map_cmd("<Left>"):desc("editc: Left"),
	["c|<C-f>"] = map_cmd("<Right>"):desc("editc: Right"),
	["c|<C-a>"] = map_cmd("<Home>"):desc("editc: Home"),
	["c|<C-e>"] = map_cmd("<End>"):desc("editc: End"),
	["c|<C-d>"] = map_cmd("<Del>"):desc("editc: Delete"),
	["c|<C-h>"] = map_cmd("<BS>"):desc("editc: Backspace"),
	["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):desc("editc: Complete path of current file"),
	-- Visual mode
	["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):desc("editv: Move this line down"),
	["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):desc("editv: Move this line up"),
	["v|<"] = map_cmd("<gv"):desc("editv: Decrease indent"),
	["v|>"] = map_cmd(">gv"):desc("editv: Increase indent"),
}

require("config.keymaps.alpha")

return keymaps
