-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/gopls.lua
return {
  flags = { debounce_text_changes = 500 },
  cmd = { "gopls", "serve" },
  -- root_dir = require("lspconfig.util").root_pattern({ ".git", "go.work" }), -- Don't use go.mod!?
  root_dir = require("lspconfig.util").root_pattern({ ".git" }), -- Don't use go.mod!?
  single_file_support = true, -- enable this?
  settings = {
    gopls = {
      usePlaceholders = true,
      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusewrites = true,
      },
    },
  },
}
