-- require("smartyank").setup({
-- 	highlight = { enabled = true, timeout = 270 },
-- 	clipboard = { enabled = false },
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
})
