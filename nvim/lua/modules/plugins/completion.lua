local M = {}

M["neovim/nvim-lspconfig"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("completion.lsp"),
}

M["Jint-lzxy/lsp_signature.nvim"] = {
  lazy = true,
  event = "VeryLazy",
  config = require("completion.lsp-signature"),
}

M["nvimdev/lspsaga.nvim"] = {
  lazy = true,
  event = "LspAttach",
  config = require("completion.lspsaga"),
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

M["penglei/nvim-cmp"] = {
  lazy = true,
  event = "InsertEnter",
  config = require("completion.cmp"),
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = require("completion.luasnip"),
    },
    { "rafamadriz/friendly-snippets" },
    { "lukas-reineke/cmp-under-comparator" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },
    -- { "andersevenrud/cmp-tmux" },
    { "hrsh7th/cmp-path" },
    { "f3fora/cmp-spell" },
    { "hrsh7th/cmp-buffer" },
    { "kdheepak/cmp-latex-symbols" },
    { "ray-x/cmp-treesitter" },
  },
}

M["stevearc/conform.nvim"] = {
  -- event = { "BufWritePre" },
  -- cmd = { "ConformInfo" },
  lazy = false,
  config = require("completion.conform"),
}

-- completion["dense-analysis/ale"] = {
-- 	lazy = true,
-- 	event = { "BufReadPost",},
-- }

M["mfussenegger/nvim-lint"] = {
  lazy = true,
  event = "VeryLazy",
  config = function()
    require("lint").linters_by_ft = {
      markdown = { "vale" },
      --go = { "golangcilint" },
    }
  end,
}

-- M["eraserhd/parinfer-rust"] = {
--   dir = vim.fn.expand("$HOME/.config/local-nvim-plugins/parinfer-rust"),
--   config = function()
--     vim.g.parinfer_dylib_path = vim.fn.expand("$HOME/.nix-profile/lib/libparinfer_rust.dylib")
--   end,
-- }

return M
