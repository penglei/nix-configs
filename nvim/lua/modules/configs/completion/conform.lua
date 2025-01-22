local function setup_simple_lsp_formatter()
  require("completion.formatting").configure_format_on_save()
end

local function setup_conform()
  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
  end, { range = true })

  vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
      -- FormatDisable! will disable formatting just for this buffer
      vim.b.disable_autoformat = true
    else
      vim.g.disable_autoformat = true
    end
  end, {
    desc = "Disable autoformat-on-save",
    bang = true,
  })

  vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
  end, {
    desc = "Re-enable autoformat-on-save",
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  require("conform").setup({
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Disable autoformat for files in a certain path
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match("/node_modules/") then
        return
      end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    format_after_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      return { lsp_format = "never" }
    end,
    log_level = vim.log.levels.TRACE,

    -- Define your formatters
    formatters_by_ft = {
      yaml = { "yamlfmt" },
      json = { "jq" },
      nix = { "nixfmt" },
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier" },
      go = { "goimports", "gofmt" },
      proto = { "bufprotofmt" },
      bzl = { "buildifier" },
      typst = { "typstyle" },
      nickel = { "nickel" },
    },
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      goimports = {
        append_args = {
          -- 这些常用的顶层module不会被别的module引用，一定是local。
          -- 遗留问题是如何处理公共包(如khaos/pkg)? 只有按照project/lsp root来定义才行。
          "-local",
          "git.woa.com/khaos/platform,git.woa.com/khaos/apiserver,git.woa.com/khaos/scheduler",
        },
      },
      bufprotofmt = {
        command = "buf",
        args = { "format", "$FILENAME" },
      },
      -- yamlfmt = { prepend_args = { "-conf", ".yamlfmt.yaml" } },
      yamlfmt = function(bufnr)
        local config_file = vim.fs.find({ ".yamlfmt.yaml", ".yamlfmt", ".yamlfmt.yml" }, { upward = true })[1]
        local args
        if config_file then
          args = { "-conf", config_file, "-" }
        else
          args = { "-" }
        end
        -- vim.notify(args)
        return {
          --command = require("conform.util").find_executable({ "~/.local/bin/yamlfmt" }, "yamlfmt"),
          command = "yamlfmt",
          args,
        }
      end,
    },
  })
end

return function()
  -- setup_simple_lsp_formatter()
  setup_conform()
end
