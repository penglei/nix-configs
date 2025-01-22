local M = {}

-- editor["rmagatti/auto-session"] = {
-- 	lazy = true,
-- 	cmd = { "SessionSave", "SessionRestore", "SessionDelete" },
-- 	config = require("editor.auto-session"),
-- }

-- A minimalist Neovim plugin that auto pairs & closes brackets
M["m4xshen/autoclose.nvim"] = {
  lazy = true,
  event = "InsertEnter",
  config = require("editor.autoclose"),
}

--jj/jk as esc
M["max397574/better-escape.nvim"] = {
  lazy = true,
  event = { "CursorHold", "CursorHoldI" },
  config = require("editor.better-escape"),
}

M["kylechui/nvim-surround"] = {
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
    })
  end,
}

M["ibhagwan/smartyank.nvim"] = {
  lazy = true,
  event = "BufReadPost",
  config = require("tool.smartyank"),
}

M["LunarVim/bigfile.nvim"] = {
  lazy = false,
  config = require("editor.bigfile"),
  cond = require("core.settings").load_big_files_faster,
}

-- symbols outline has provided by lspsaga
-- editor["penglei/symbols-outline.nvim"] = {
-- 	lazy = true,
-- 	cmd = { "SymbolsOutline", "SymbolsOutlineOpen", "SymbolsOutlineClose" },
-- 	config = require("tool.symbols-outline"),
-- }

-- --bug: 这个插件可能跟其它插件有冲突，使用这个插件关闭buffer可能导致swap文件没删除。
-- editor["ojroques/nvim-bufdel"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- }
M["famiu/bufdelete.nvim"] = {
  lazy = true,
  event = "VeryLazy",
}

M["rhysd/clever-f.vim"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("editor.cleverf"),
}

M["numToStr/Comment.nvim"] = {
  lazy = true,
  event = { "CursorHold", "CursorHoldI" },
  config = require("editor.comment"),
}

M["RRethy/vim-illuminate"] = { -- highlighting other word under cursor
  lazy = true,
  event = { "CursorHold", "CursorHoldI" },
  config = require("editor.vim-illuminate"),
}
M["romainl/vim-cool"] = { -- better search highlighting
  lazy = true,
  event = { "CursorMoved", "InsertEnter" },
}

M["smoka7/hop.nvim"] = {
  lazy = true,
  --branch = "v2",
  event = "BufReadPost",
  config = function()
    require("hop").setup({
      keys = "etovxqpdygfblzhckisuran",
      multi_windows = true,
      hint_position = require("hop.hint").HintPosition.END,
    })
  end,
}

-- 三个字符跳到任何窗口中任何位置。
-- 绑定的快捷键： 's': forward; 'S': backward;
-- 不要使用lazy加载leap，它会导致hop 的 gs无法工作.
M["ggandor/leap.nvim"] = { -- s{first char}{second char}{Leap Hit}
  lazy = false,
  -- event = "BufReadPost",
  config = function()
    local opts = require("leap").opts
    -- safe_labels = {"s", "f", "n", "u", "t", "/", "S", "F", "N", "L", "H", "M", "U", "G", "T", "Z", "?"},
    -- opts.labels = { "s", "f", "n", "j", "k", "l", "h", "o", "d", "w", "e", "i", "m", "b", "u", "y", "v", "r", "g", "t", "a", "q", "p", "c", "x", "z", "/", "S", "F", "N", "J", "K", "L", "H", "O", "D", "W", "E", "I", "M", "B", "U", "Y", "V", "R", "G", "T", "A", "Q", "P", "C", "X", "Z", "?", }
  end,
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
M["nvim-treesitter/nvim-treesitter"] = {
  build = function()
    if #vim.api.nvim_list_uis() ~= 0 then
      vim.api.nvim_command("TSUpdate")
    end
  end,
  event = { "CursorHold", "CursorHoldI" },
  -- event = { "BufReadPost" },
  config = require("editor.treesitter"),
  dependencies = {
    { "andymass/vim-matchup" },
    { "mfussenegger/nvim-treehopper" },
    { "nvim-treesitter/nvim-treesitter-textobjects" },
    {
      "windwp/nvim-ts-autotag",
      config = require("editor.autotag"),
    },
    {
      "NvChad/nvim-colorizer.lua",
      config = require("editor.colorizer"),
    },
    {
      "hiphish/rainbow-delimiters.nvim",
      -- url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
      config = require("editor.rainbow_delims"),
    },
    -- { "nvim-treesitter/nvim-treesitter-context" }, #head line show syntax block context
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      config = require("editor.ts-context-commentstring"),
    },
  },
}

return M
