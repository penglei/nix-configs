return function()
  require("blink.cmp").setup({
    keymap = {
      preset = "enter",
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
    },
    -- cmdline = { sources = { "cmdline" } },
    sources = {
      default = { "lsp", "buffer", "codecompanion", "snippets", "path" },
    },
  })
end
