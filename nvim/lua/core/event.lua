-- Now use `<A-k>` or `<A-1>` to back to the `dotstutor`.
local autocmd = {}

function autocmd.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command("augroup " .. group_name)
    vim.api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command("augroup END")
  end
end

-- auto close NvimTree
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
  pattern = "NvimTree_*",
  callback = function()
    local layout = vim.api.nvim_call_function("winlayout", {})
    if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
      vim.api.nvim_command([[confirm quit]])
    end
  end,
})

-- auto close some filetype with <q>
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "nofile",
    "lspinfo",
    "terminal",
    "prompt",
    "toggleterm",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
    "fugitive",
    "sagarename",
    "lspsagacallhierarchy",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
  end,
})

vim.filetype.add({
  extension = {
    ["typst"] = "typst",
  },
})

local function create_filetype_map(ft, mode, lhs, rhs)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { ft },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.api.nvim_buf_set_keymap(event.buf, mode, lhs, rhs, { silent = true })
    end,
  })
end
create_filetype_map("alpha", "n", "q", "<CMD>q<CR>")
create_filetype_map("lspsagaoutline", "n", "<C-o>", "q")
create_filetype_map("Outline", "n", "<C-o>", "q")

-- Fix fold issue of files opened by telescope
vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      once = true,
      command = "normal! zx",
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FixTerraformCommentString", { clear = true }),
  callback = function(ev)
    vim.bo[ev.buf].commentstring = "# %s"
  end,
  pattern = { "terraform", "hcl" },
})

function autocmd.load_autocmds()
  local definitions = {
    lazy = {},
    bufs = {
      -- Reload vim config automatically
      {
        "BufWritePost",
        [[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]],
      },
      -- Reload Vim script automatically if setlocal autoread
      {
        "BufWritePost,FileWritePost",
        "*.vim",
        [[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]],
      },
      { "BufWritePre", "/tmp/*", "setlocal noundofile" },
      { "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
      { "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
      { "BufWritePre", "*.tmp", "setlocal noundofile" },
      { "BufWritePre", "*.bak", "setlocal noundofile" },
      -- auto place to last edit
      { "BufReadPost", "*", [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]] },
      { "BufRead,BufNewFile", "*.ncl,*.nkl", "set filetype=nickel" },
      { "BufRead,BufNewFile", "*.dhall", "set filetype=dhall" },
      { "BufRead,BufNewFile", "*.lalrpop", "set filetype=lalrpop" },
      { "BufRead,BufNewFile", "*.bxl,BUCK,TARGETS", "set filetype=bzl" },
    },
    wins = {
      -- Highlight current line only on focused window
      {
        "WinEnter,BufEnter,InsertLeave",
        "*",
        [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
      },
      {
        "WinLeave,BufLeave,InsertEnter",
        "*",
        [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
      },
      -- Force write shada on leaving nvim
      {
        "VimLeave",
        "*",
        [[if has('nvim') | wshada! | else | wviminfo! | endif]],
      },
      -- Check if file changed when its window is focus, more eager than 'autoread'
      { "FocusGained", "* checktime" },
      -- Equalize window dimensions when resizing vim window
      { "VimResized", "*", [[tabdo wincmd =]] },
    },
    ft = {
      { "FileType", "alpha", "set showtabline=0" },
      { "FileType", "markdown", "set wrap" },
      { "FileType", "make", "set noexpandtab shiftwidth=4 softtabstop=0" },
      -- { "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
      { "FileType", "*", [[setlocal formatoptions-=cro]] },
      { "FileType", "c,cpp", "nnoremap <leader>h :ClangdSwitchSourceHeaderVSplit<CR>" },
      { "FileType", "yaml,json", "set shiftwidth=2 " },
      { "FileType", "go", "set tabstop=2 shiftwidth=2" },
      { "FileType", "scheme", "set shiftwidth=2" },
      { "FileType", "lua", "set expandtab shiftwidth=2" },
      { "FileType", "nickel", "setlocal commentstring=#%s" },
    },
    yank = {
      { "TextYankPost", "*", [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]] },
    },
  }

  autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()
