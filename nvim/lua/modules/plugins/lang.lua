local M = {}

M["ray-x/go.nvim"] = {
  lazy = true,
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup({
      diagnostic = false,
      dap_debug = false,
      luasnip = true,
    })
  end,
  -- event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}

M["simrat39/rust-tools.nvim"] = {
  lazy = true,
  ft = "rust",
  config = require("lang.rust-tools"),
  dependencies = { "nvim-lua/plenary.nvim" },
}
M["Saecki/crates.nvim"] = {
  lazy = true,
  event = "BufReadPost Cargo.toml",
  config = require("lang.crates"),
  dependencies = { "nvim-lua/plenary.nvim" },
}

M["iamcco/markdown-preview.nvim"] = {
  lazy = true,
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browser = "Safari"
  end,
  build = ":call mkdp#util#install()",
}

M["chomosuke/typst-preview.nvim"] = {
  -- version = "0.3.*",
  ft = "typst",
  build = function()
    require("typst-preview").update()
  end,
  config = require("lang.typst"),
}

M["kaarmu/typst.vim"] = {
  ft = "typst",
}

M["chrisbra/csv.vim"] = {
  lazy = true,
  ft = "csv",
}

M["edgedb/edgedb-vim"] = {
  lazy = true,
  ft = "edgeql",
}

M["sdiehl/vim-cabalfmt"] = {
  lazy = true,
  event = "BufReadPost",
}

return M
