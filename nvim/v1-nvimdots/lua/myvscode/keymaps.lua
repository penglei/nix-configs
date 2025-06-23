local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
-- keymap({ "n", "v" }, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
keymap({ "n", "v" }, "<leader>k", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")

-- next problem in file
keymap({ "n", "v" }, "<leader>n", "<cmd>lua require('vscode').action('editor.action.marker.nextInFiles')<CR>")
-- previous problem in file
keymap({ "n", "v" }, "<leader>p", "<cmd>lua require('vscode').action('editor.action.marker.prevInFiles')<CR>")
