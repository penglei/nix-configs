local bind = require("keymap.bind")
local keymap = require("keymap")

-- https://superuser.com/questions/770068/in-vim-how-can-i-remap-tab-without-also-remapping-ctrli
-- 终端中 <C-i> 的键码与 <Tab> 相同，若你自定义了 <Tab> 的映射，会覆盖 <C-i>
vim.keymap.set("n", "<C-i>", "<C-i>", { noremap = true }) -- 确保 <C-i> 不被覆盖

bind.nvim_load_mapping(keymap.core)
bind.nvim_load_mapping(keymap.basic)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    bind.nvim_load_mapping(keymap.buf(event.buf))
  end,
})
