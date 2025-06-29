-- https://fredrikaverpil.github.io/neotest-golang/recipes/#example-configuration-extra-everything

return function()
  vim.api.nvim_create_user_command("ToggleNeotestSummary", function()
    require("neotest").summary.toggle()
  end, {
    desc = "Neotest: toggle summary",
  })

  vim.api.nvim_create_user_command("ToggleNeotestOutputPanel", function()
    require("neotest").output_panel.toggle()
  end, {
    desc = "Neotest: toggle output panel",
  })

  vim.api.nvim_create_user_command("TerminateNeotest", function()
    require("neotest").run.stop()
  end, {
    desc = "Neotest: terminate running test",
  })

  vim.api.nvim_create_user_command("NeotestRun", function()
    require("neotest").run.run()
  end, {
    desc = "Neotest: terminate running test",
  })

  vim.api.nvim_create_user_command("ShowTestOutput", function()
    require("neotest").output.open({ enter = true })
  end, {
    desc = "Neotest: terminate running test",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "neotest-summary",
      "neotest-output-panel",
      "neotest-output",
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "neotest-output" },
    callback = function(event)
      vim.api.nvim_buf_set_keymap(event.buf, "n", "<Esc>", [[<C-\><C-n>:q!<CR>]], { noremap = true, silent = true })
    end,
  })

  local neotest_golang_opts = {} -- Specify custom configuration
  require("neotest").setup({
    adapters = {
      require("neotest-golang")(neotest_golang_opts), -- Registration
    },
  })
end
