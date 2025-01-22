return function()
  local icons = {
    ui = require("modules.utils.icons").get("ui"),
    misc = require("modules.utils.icons").get("misc"),
  }

  require("which-key").setup({
    plugins = {
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = true,
        g = true,
      },
    },

    icons = {
      breadcrumb = icons.ui.Separator,
      separator = icons.misc.Vbar,
      group = icons.misc.Add,
    },
  })
end
