local bind = require("keymap.bind")
local keymap = require("keymap")

bind.nvim_load_mapping(keymap.core)
bind.nvim_load_mapping(keymap.basic)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    bind.nvim_load_mapping(keymap.buf(event.buf))
  end,
})
