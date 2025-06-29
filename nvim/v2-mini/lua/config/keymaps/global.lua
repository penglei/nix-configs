local util = require("config.util")

local map_cr = util.bind.map_cr
local map_cu = util.bind.map_cu
local map_cmd = util.bind.map_cmd

-- https://superuser.com/questions/770068/in-vim-how-can-i-remap-tab-without-also-remapping-ctrli
-- 终端中 <C-i> 的键码与 <Tab> 相同，若自定义了 <Tab> 的映射，则会覆盖 <C-i>
vim.keymap.set("n", "<C-i>", "<C-i>", { noremap = true }) -- 确保 <C-i> 不被覆盖

-- set a global key mapping:  ',' as another leader key
vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

return {
	["n|<leader>e"] = map_cr("NvimTreeFindFile"):desc("nvim-tree: Find file"),

	["n|<leader>f"] = map_cu("Pick files"):desc("Mini: Pick file"),
	["n|<leader>b"] = map_cu("Pick buffers"):desc("Mini: Pick buffer"),
	["n|<leader>c"] = map_cu("Pick commands"):desc("Mini: Pick command"),

	["n|<leader>q"] = map_cu("exit"):desc("exit"),
	["n|<leader>d"] = map_cu("Bdelete"):desc("delete current buffer"),

	-- Plugin: toggleterm
	["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]),
	["n|<C-'>"] = map_cr([[execute v:count . "ToggleTerm direction=float"]]):desc("terminal: Toggle float"),
	["i|<C-'>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=float<CR>"):desc("terminal: Toggle float"),
	["t|<C-'>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):desc("terminal: Toggle float"),

	-- Plugin: nvim-treehopper
	-- o: Operator-pending mode. 先按了操作(e.g.  y(复制),d(删除),c(修改))进入等待范围选择，
	--    这是因为vim的操作习惯是先输入的[操作]，再输入[范围]。
	["o|m"] = map_cu("lua require('tsht').nodes()"):desc("Operator-pending: motion syntax tree"),
	["n|gm"] = map_cu("lua require('tsht').nodes()"):desc("treehopper: visual select with motion syntax tree"),
	["n|m"] = map_cu("lua require('tsht').nodes()"):desc("treehopper: visual select with motion syntax tree"),

	---------------- core ---------------
	["n|<Tab>"] = map_cr("BufferLineCycleNext"):desc("goto next buffer"),
	["n|<S-Tab>"] = map_cr("BufferLineCyclePrev"):desc("goto prev buffer"),

	["n|Y"] = map_cmd("y$"):desc("editn: Yank text to EOL"),
	["n|D"] = map_cmd("d$"):desc("editn: Delete text to EOL"),
	-- ["n|n"] = map_cmd("nzzzv"):desc("editn: Next search result"),
	-- ["n|N"] = map_cmd("Nzzzv"):desc("editn: Prev search result"),
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
