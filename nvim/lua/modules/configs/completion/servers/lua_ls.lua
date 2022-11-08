-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/lua_ls.lua

local lazy_lib_path = vim.fn.stdpath("data") .. "/lazy"

local config = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        disable = { "different-requires" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,

          [lazy_lib_path .. "/cmp-nvim-lsp"] = true,
          [lazy_lib_path .. "/telescope.nvim"] = true,
          [lazy_lib_path .. "/conform.nvim"] = true,
          [lazy_lib_path .. "/nvim-lint"] = true,
          [lazy_lib_path .. "/go.nvim"] = true,
          [lazy_lib_path .. "/nvim-lspconfig"] = true,
          [lazy_lib_path .. "/harpoon"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
      telemetry = { enable = false },
      -- Do not override treesitter lua highlighting with lua_ls's highlighting
      semantic = { enable = false },
    },
  },
}

return config
