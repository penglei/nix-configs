return function()
  local lspconfig = require("lspconfig")

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    signs = true,
    underline = true,

    -- Set it to false if diagnostics virtual text is annoying.
    virtual_text = true,

    -- set update_in_insert to false bacause it was enabled by lspsaga
    update_in_insert = false,
  })

  local common_opts = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  }

  local get_server_opts = function(lsp_name)
    local ok, server_opts = pcall(require, "completion.servers." .. lsp_name)
    if ok and type(server_opts) == "table" then
      return server_opts
    else
      -- vim.notify(string.format("server:%s opt is not table", lsp_name), vim.log.levels.WARN, {
      --   title = "Lsp setup",
      -- })
      return {}
    end
  end

  local setup_lsp = function(lsp_name, opts)
    if opts == nil then
      opts = {}
    end
    local lsp_opts = vim.tbl_deep_extend("force", common_opts, opts)
    local final_opts = vim.tbl_deep_extend("force", get_server_opts(lsp_name), lsp_opts)
    lspconfig[lsp_name].setup(final_opts)
  end

  setup_lsp("lua_ls")
  setup_lsp("clangd")
  setup_lsp("bashls", { cmd = { "bash-language-server", "start" }, filetypes = { "bash", "sh" } })
  setup_lsp("pylsp")
  setup_lsp("gopls")
  setup_lsp("html")
  setup_lsp("hls", { filetypes = { "haskell", "lhaskell" } })
  setup_lsp("ocamllsp")
  setup_lsp("nickel_ls")
  setup_lsp("nil_ls")
  setup_lsp("buck2")
  setup_lsp("pbls")
  -- setup_lsp("typst_lsp", { exportPdf = "onSave" })
  setup_lsp("tinymist", { settings = { exportPdf = "onSave", outputPath = "$root/target/$dir/$name" } })
  -- setup_lsp("starlark_rust")

  setup_lsp("jsonls")
  setup_lsp("yamlls", {
    settings = {
      yaml = {
        schemas = {
          -- default any schema to prevent lsp schema diagnostic error
          [vim.fn.stdpath("config") .. "/config/schema-any.yaml"] = "/*",
        },
      },
    },
  })
  if vim.fn.executable("dart") == 1 then
    setup_lsp("dartls")
  end
  if vim.fn.executable("deno") == 1 then
    setup_lsp("denols", { cmd = { "deno", "lsp" } })
  end
  -- lspconfig.tsserver.setup{}

  vim.api.nvim_command("LspStart") -- Start LSPs
end
