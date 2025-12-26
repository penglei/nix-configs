---@diagnostic disable: missing-parameter

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
vim.api.nvim_set_keymap("n", "s", "", { noremap = true })

-- vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
-- mode tips:
-- :h Visual-mode
-- :h Select-mode

-- :h mapmode-x: activated only in visual mode
-- :h mapmode-s: activated only in select mode
-- :h mapmode-v: activated in both visual and select mode
-- o: Operator-pending mode: 先按了操作(e.g.  y(复制),d(删除),c(修改))进入等待范围选择的模式。vim的操作习惯是先输入[操作]，再输入[范围]。

local leap_jump_wins = function() require("leap").leap({ target_windows = require("leap.user").get_focusable_windows() }) end
---@diagnostic disable-next-line: unused-function, unused-local
local leap_jump_buf = function() require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } }) end

-- stylua: ignore start
-- 1. try `,pn` on `foo` or {}
-- 2. try `,pp` on `b` or "2"
-- 3. try `,s` to split arguments
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

	["n|,w"] = map_cmd("<esc>:w<cr>"):desc("save"),
	["sinv|<C-s>"] = map_cmd("<esc>:w<cr>"):desc("Exit insert mode and save changes"),

	["i|<C-h>"] = map_cmd("<Left><Del>"):desc("Delete one char before cursor"),
	["i|<C-f>"] = map_cmd("<Right>"):desc("Cursor move forward"),
	["i|<C-e>"] = map_cmd("<End>"):desc("Cursor move to line end"),

	["n|<leader>o"] = map_cb(function() require("outline").toggle_outline() end):desc("Toggle the outline window."),

	["n|<leader><space>"] = map_cb(function() Snacks.picker() end):desc("All pickers"),
	["n|<leader>e"] = map_cr("NvimTreeFindFile"):desc("nvim-tree: Find file"),
	["n|<leader>y"] = map_cmd("<CMD>lua MiniFiles.open()<CR>"):desc("open mini files navigator"), -- like command 'yazi'
	-- ["n|<leader>y"] = map_cmd("<CMD>lua require('yazi').yazi()<CR>"):desc("open mini files navigator"),

	-- ["xn|<leader>g"] = map_cb("Pick grep_live"):desc("Mini: Pick grep words"),
	["n|<leader>/"] = map_cb(function() Snacks.picker.grep() end):desc("Snacks picker: grep words"),
	-- ["n|<leader>f"] = map_cu("Pick files"):desc("Mini: Pick file"),
	["n|<leader>f"] = map_cb(function() Snacks.picker.smart() end):desc("Smart Find Files"),
	-- ["n|<leader>b"] = map_cu("Pick buffers"):desc("Mini: Pick buffer"),
	["n|<leader>b"] = map_cb(function() Snacks.picker.buffers() end):desc("Buffers"),
	["n|<leader>r"] = map_cb(function() Snacks.picker.recent() end):desc("Recent files"),
	-- ["n|<leader>c"] = map_cu("Pick commands"):desc("Mini: Pick command"),
	["n|<leader>c"] = map_cb(function() Snacks.picker.commands() end):desc("Commands"),
	["n|<leader>:"] = map_cb(function() Snacks.picker.command_history() end):desc("Command History"),
	["xn|<leader>w"] = map_cb(function() Snacks.picker.grep_word() end):desc("Visual selection or word"),
	["n|<leader>sj"] = map_cb(function() Snacks.picker.jumps() end):desc("Jumps"),
	["n|<leader>sk"] = map_cb(function() Snacks.picker.keymaps() end):desc("Keymaps"),
	["n|<leader>sm"] = map_cb(function() Snacks.picker.marks() end):desc("Marks"),
	["n|<leader>sd"] = map_cb(function() Snacks.picker.diagnostics_buffer() end):desc("Buffer Diagnostics"),
	["n|<leader>sD"] = map_cb(function() Snacks.picker.diagnostics() end):desc("Diagnostics"),
	["n|<leader>sq"] = map_cb(function() Snacks.picker.qflist() end):desc("Quickfix List"),
	["n|<leader>uC"] = map_cb(function() Snacks.picker.colorschemes() end):desc("Colorschemes"),
	-- ["n|<leader>n"] = map_cb(function() Snacks.picker.notifications() end):desc("Notification History"),

	["n|<leader>q"] = map_cu("q"):desc("exit"),
	["n|<leader>x"] = map_cb(function() Snacks.bufdelete() end):desc("Delete current buffer"),
	["n|<Esc><Esc>"] = map_cb(function()
		vim.cmd("nohl") -- vim.cmd.nohlsearch()
		require("todo-comments").disable()
		-- TODO: chain more auto action
		vim.api.nvim_feedkeys(util.bind.escape_termcode("<ESC>"), "n", true)
	end):desc("Clean(nohl, todo-comments)"),
	["i|<Esc>"] = map_cb(function()
		-- if cmp menu is visible, close it first
		local cmp = require("blink.cmp")
		local ai = require("config.editing.ai")

		if cmp.is_menu_visible() and ai.virtext_sugg.is_visible() then
			-- close cmp menu then we can press <Tab> to accept ai suggestion
			cmp.hide()
			return
		end
		-- fallback to normal esc behaviour
		vim.api.nvim_feedkeys(util.bind.escape_termcode("<ESC>"), "n", true)
	end):desc("Exit insert mode"),

	-- reverse p and P behaviour in visual mode
	["v|p"] = map_cb(visual_lower_p):desc("paste in visual mode"),
	["v|P"] = map_cb(visual_upper_p):desc("paste and override default register"),
	-- <BS> has mapped to wilder in visual mode, so we need to bind to **selection mode** to dinstict from it while press <BS>.
	["s|<BS>"] = map_cmd('<C-G>"_<DEL>'):desc("delete text without overriding default register"),
	["v|<S-BS>"] = map_cmd('"_<DEL>'):desc("delete text without overriding default register"),

	["n|,pi"] = map_cr("PasteImage"):desc("Paste image from system clipboard"),

	-- ["n|<leader>r"] = map_cr("Rename"):desc("lsp: Rename current word"),
	-- ["n|<leader>R"] = map_cr("LspRestart"):desc("lsp: Restart lsp server"),

	----------------- command line ----------------------
	["c|<C-p>"] = map_cmd("<Up>"),
	["c|<C-n>"] = map_cmd("<Down>"),

	------------------- terminal ------------------------
	["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]):desc("terminal enter normal mode "),

	-- ["n|<C-'>"] = map_cr([[execute v:count1 . "ToggleTerm direction=float"]]) -- select terminal by id that comes from v:count.
	["in|<C-'>"] = map_cb(function() ToggleFloatTerm() end):desc("terminal: Toggle float"),
	["t|<C-'>"] = map_cb(function() CloseFloatTerm() end):desc("terminal: close float"),

	["in|<C-0>"] = map_cb(function() ToggleBottomTerm() end):desc("terminal: Toggle bottom"),
	["t|<C-0>"] = map_cb(function() CloseBottomTerm() end):desc("terminal: Toggle bottom"),

	-----------------------------------------------------
	---
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
	-- ["n|<C-p>"] = map_cb(function() require("hover").hover_switch("previous") end):desc("hover.nvim (previous source)"),
	-- ["n|<C-n>"] = map_cb(function() require("hover").hover_switch("next") end):desc("hover.nvim (next source)"),

	----------------- motion/selection ------------------
	---------- flash
	["vn|'w"] = map_cb(function() require("flash").jump() end):desc("flash: jump in all windows"),
	["xn|gw"] = map_cb(function() require("flash").treesitter_search() end):desc("flash: select syntax node in current window"),
	["nxo|mm"] = map_cb(function() require("flash").treesitter() end):desc("flash: select syntax node in local scopes"),
	["n|gs"] = map_cb(function() require("flash").jump({ pattern = vim.fn.expand("<cword>") }) end):desc("flash: search word"),
	---------- leap
	-- ["vn|'w"] = map_cb(leap_jump_wins):desc("leap: jump in all windows"),
	-- ["xn|'wb"] = map_cb(leap_jump_buf):desc("leap: jump/select in current window"),
	["n|gm"] = map_cr("TreesitterNodeLeap"):desc("leap treesitter jump/select in local scope"), -- BUG: TODO support visual mode
	-- ["nxo|mm"] = map_cb(function() require("leap.treesitter").select() end):desc("leap: select syntax node in local scopes"),
	---------- tsht: nvim-treehopper
	-- -- ["n|gm"] = map_cu("HopWord"):desc("Hop: jump to a word in any window"),
	-- -- ["v|gm"] = map_cb(function() require("hop").hint_words() end):desc("Hop: select range to a word"),
	-- ["no|'s"] = map_cu("lua require('tsht').nodes()"):desc("Treehopper: syntax tree selection"),
	-- 因为's'是surround快捷键的前缀，所以我们需要一种方式快速进入syntax tree selection mode, 而不是等待 vim.opt.timeoutlen
	-- ["no|s<CR>"] = map_cu("lua require('tsht').nodes()"):desc("Treehopper: enter syntax selection quickly"),

	------------- test ------------------
	-- ["n|<C-t>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>t<CR>"] = map_cr("NeotestRun"):desc("Neotest: Run cursor nearest test"),
	["n|<leader>to"] = map_cr("ShowTestOutput"):desc("Neotest: show cursor test output"),

	------------ comment -----------------
	-- comment key mapping is configured in config.editing.comment and config.ui.mini.clue
	-- ["n|,/"] -- singline comment toggle
	-- ["v|,/"] -- multiline comment toggle

	-------------- core ----------------
	["x|S"] = map_cmd([[:<C-u>lua MiniSurround.add('visual')<CR>]]):desc("surround in visual mode"),
	["vn|gh"] = map_cmd("^"):desc("Goto line word start"),
	["vn|gH"] = map_cmd("0"):desc("Goto line start"),
	["vn|gl"] = map_cmd("g_"):desc("Goto line last word end"),
	["vn|gL"] = map_cmd("$"):desc("Goto line end"),
	["vn|ge"] = map_cmd("G"):desc("Goto last line"),
	-- ["n|gg"] -- editor default. go to first line.

	["n|<Tab>"] = map_cr("BufferLineCycleNext"):desc("goto next buffer"),
	["n|<S-Tab>"] = map_cr("BufferLineCyclePrev"):desc("goto prev buffer"),
	-- ["n|<C-n>"] = map_cr("BufferLineCycleNext"):desc("goto next buffer"),
	-- ["n|<C-p>"] = map_cr("BufferLineCyclePrev"):desc("goto prev buffer"),

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
	["c|<C-b>"] = map_cmd("<Left>"):nowait(true):desc("editc: Left"),
	["c|<C-f>"] = map_cmd("<Right>"):nowait(true):desc("editc: Right"),
	["c|<C-a>"] = map_cmd("<Home>"):nowait(true):desc("editc: Home"),
	["c|<C-e>"] = map_cmd("<End>"):nowait(true):desc("editc: End"),
	["c|<C-d>"] = map_cmd("<Del>"):nowait(true):desc("editc: Delete"),
	["c|<C-h>"] = map_cmd("<BS>"):nowait(true):desc("editc: Backspace"),
	["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):desc("editc: Complete path of current file"),
	-- Visual mode
	["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):desc("editv: Move this line down"),
	["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):desc("editv: Move this line up"),
	["v|<"] = map_cmd("<gv"):desc("editv: Decrease indent"),
	["v|>"] = map_cmd(">gv"):desc("editv: Increase indent"),
}

require("config.keymaps.alpha")

return keymaps
