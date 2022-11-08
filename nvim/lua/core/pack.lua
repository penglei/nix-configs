local global = require("core.global")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local modules_dir = global.vim_path .. "/lua/modules"

local icons = {
  kind = require("modules.utils.icons").get("kind"),
  documents = require("modules.utils.icons").get("documents"),
  ui = require("modules.utils.icons").get("ui"),
  ui_sep = require("modules.utils.icons").get("ui", true),
  misc = require("modules.utils.icons").get("misc"),
}

local Lazy = {}

function Lazy:ensure_loader()
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath
    })
  end

  local lazy_settings = {
    git = {
      -- log = { "-10" }, -- show the last 10 commits
      timeout = 300,
    },
    install = {
      -- install missing plugins on startup. This doesn't increase startup time.
      missing = true,
      colorscheme = { "catppuccin" },
    },
    ui = {
      -- a number <1 is a percentage., >1 is a fixed size
      size = { width = 0.88, height = 0.8 },
      wrap = true, -- wrap the lines in the ui
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = "rounded",
      icons = {
        cmd = icons.misc.Code,
        config = icons.ui.Gear,
        event = icons.kind.Event,
        ft = icons.documents.Files,
        init = icons.misc.ManUp,
        import = icons.documents.Import,
        keys = icons.ui.Keyboard,
        loaded = icons.ui.Check,
        not_loaded = icons.misc.Ghost,
        plugin = icons.ui.Package,
        runtime = icons.misc.Vim,
        source = icons.kind.StaticMethod,
        start = icons.ui.Play,
        list = {
          icons.ui_sep.BigCircle,
          icons.ui_sep.BigUnfilledCircle,
          icons.ui_sep.Square,
          icons.ui_sep.ChevronRight,
        },
      },
    },
    performance = {
      cache = {
        enabled = true,
        path = vim.fn.stdpath("cache") .. "/lazy/cache",
        -- Once one of the following events triggers, caching will be disabled.
        -- To cache all modules, set this to `{}`, but that is not recommended.
        disable_events = { "UIEnter", "BufReadPre" },
        ttl = 3600 * 24 * 2, -- keep unused modules for up to 2 days
      },
      reset_packpath = true, -- reset the package path to improve startup time
      rtp = {
        reset = true, -- reset the runtime path to $VIMRUNTIME and the config directory
        ---@type string[]
        paths = {}, -- add any custom paths here that you want to include in the rtp
      },
    },
  }
  return lazy_settings
end

function Lazy:plugins()
  return {
    require("modules.plugins.ui"),
    require("modules.plugins.completion"),
    require("modules.plugins.editor"),
    require("modules.plugins.lang"),
    require("modules.plugins.tool"),
  }
end

function Lazy:load_plugins()
  local plugin_modules = {}

  for _, p in ipairs(self:plugins()) do
    if type(p) == "table" then
      for name, conf in pairs(p) do
        plugin_modules[#plugin_modules + 1] = vim.tbl_extend("force", { name }, conf)
      end
    end
  end
  return plugin_modules
end

function Lazy:load()
  package.path = package.path .. string.format(";%s;%s", modules_dir .. "/configs/?.lua", modules_dir .. "/configs/?/init.lua")

  local plugin_modules = self:load_plugins()
  local lazy_settings = self:ensure_loader()
  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup(plugin_modules, lazy_settings)
end

Lazy:load()
