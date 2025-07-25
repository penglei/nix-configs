local function switch_source_header_splitcmd(bufnr, splitcmd)
  -- bufnr = require("lspconfig").util.validate_bufnr(bufnr)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  -- local clangd_client = require("lspconfig").util.get_active_client_by_name(bufnr, "clangd")
  local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
  if clangd_client then
    local method = "textDocument/switchSourceHeader"
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    local handler = function(err, result)
      if err then
        error(tostring(err))
      end
      if not result then
        vim.notify("Corresponding file can’t be determined", vim.log.levels.ERROR, { title = "LSP Error!" })
        return
      end
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    clangd_client.request(method, params, handler)
  else
    vim.notify("Method textDocument/switchSourceHeader is not supported by any active server on this buffer", vim.log.levels.ERROR, { title = "LSP Error!" })
  end
end

local function get_binary_path_list(binaries)
  local path_list = {}
  for _, binary in ipairs(binaries) do
    local path = vim.fn.exepath(binary)
    if path ~= "" then
      table.insert(path_list, path)
    end
  end
  return table.concat(path_list, ",")
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
return {
  -- capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, options.capabilities),
  capabilities = { offsetEncoding = { "utf-16", "utf-8" } },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  single_file_support = true,
  cmd = {
    "clangd",
    "-j=12",
    "--enable-config",
    "--background-index",
    "--pch-storage=memory",
    -- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
    -- "--query-driver=" .. get_binary_path_list({ "clang++", "clang", "gcc", "g++" }),
    "--query-driver=" .. get_binary_path_list({ "clang++", "clang" }),
    "--clang-tidy",
    "--all-scopes-completion",
    "--completion-style=detailed",
    "--header-insertion-decorators",
    "--header-insertion=iwyu",
    "--limit-references=3000",
    "--limit-results=350",
  },
  commands = {
    ClangdSwitchSourceHeader = {
      function()
        switch_source_header_splitcmd(0, "edit")
      end,
      description = "Open source/header in current buffer",
    },
    ClangdSwitchSourceHeaderVSplit = {
      function()
        switch_source_header_splitcmd(0, "vsplit")
      end,
      description = "Open source/header in a new vsplit",
    },
    ClangdSwitchSourceHeaderSplit = {
      function()
        switch_source_header_splitcmd(0, "split")
      end,
      description = "Open source/header in a new split",
    },
  },
}
