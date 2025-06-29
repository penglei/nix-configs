return function()
  require("trailblazer").setup({
    trail_options = {
      available_trail_mark_modes = {
        "global_chron",
        -- "global_chron_buf_switch_group_chron",
        -- "buffer_local_chron",
      },
      trail_mark_symbol_line_indicators_enabled = true,
      mark_symbol = "•", --  will only be used if trail_mark_symbol_line_indicators_enabled = true
      newest_mark_symbol = "", -- disable this mark symbol by setting its value to ""
      cursor_mark_symbol = "󰍒", -- disable this mark symbol by setting its value to ""
      next_mark_symbol = "⇟", -- disable this mark symbol by setting its value to ""
      previous_mark_symbol = "⇞", -- disable this mark symbol by setting its value to ""
    },
    mappings = { -- rename this to "force_mappings" to completely override default mappings and not merge with them
      nv = { -- Mode union: normal & visual mode. Can be extended by adding i, x, ...
        motions = {
          new_trail_mark = "ma",
          track_back = "[b",
          peek_move_next_down = "[n",
          peek_move_previous_up = "[N",
          move_to_nearest = "[l",
          -- move_to_trail_mark_cursor = "gc",
          toggle_trail_mark_list = "gm",
        },
        actions = {
          delete_all_trail_marks = "<leader>md",
          paste_at_last_trail_mark = "",
          paste_at_all_trail_marks = "",
          set_trail_mark_select_mode = "",
          switch_to_next_trail_mark_stack = "<leader>.",
          switch_to_previous_trail_mark_stack = "<leader>,",
          set_trail_mark_stack_sort_mode = "",
        },
      },
    },
  })
end
