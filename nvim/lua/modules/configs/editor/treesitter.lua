return vim.schedule_wrap(function()
  vim.api.nvim_set_option_value("foldmethod", "expr", {})
  vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "css",
      "go",
      "gomod",
      "html",
      "javascript",
      "json",
      -- "latex", -- cause parsing markdown embed latex equation failed
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "python",
      "rust",
      "typescript",
      "yaml",
      "nickel",
      "nix",
      "scheme",
      "elvish",
      "vimdoc",
    },

    highlight = {
      enable = true,
      disable = function(ft, bufnr)
        if vim.tbl_contains({ "gitcommit" }, ft) or (vim.api.nvim_buf_line_count(bufnr) > 7500 and ft ~= "vimdoc") then
          return true
        end

        local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
        return ok and is_large_file
      end,
      additional_vim_regex_highlighting = false,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]["] = "@function.outer",
          ["]m"] = "@class.outer",
        },
        goto_next_end = {
          ["]]"] = "@function.outer",
          ["]M"] = "@class.outer",
        },
        goto_previous_start = {
          ["[["] = "@function.outer",
          ["[m"] = "@class.outer",
        },
        goto_previous_end = {
          ["[]"] = "@function.outer",
          ["[M"] = "@class.outer",
        },
      },
    },
    indent = { enable = true },
    matchup = { enable = true },
  })
  require("nvim-treesitter.install").prefer_git = true
end)
