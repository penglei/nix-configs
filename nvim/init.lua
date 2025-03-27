if vim.g.vscode then
  vim.opt.clipboard = "unnamed"
  require("myvscode")
  return
end

require("core")
