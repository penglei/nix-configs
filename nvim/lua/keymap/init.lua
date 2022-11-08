local bind = require("keymap.bind")
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_cr = bind.map_cr
local map_callback = bind.map_callback
local et = bind.escape_termcode

local M = {}

-- avoid '{','}' add to jumps
vim.cmd([[
:nnoremap } :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
:nnoremap { :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>
]])

vim.keymap.set({ "n", "x", "o" }, "ga", function()
  require("leap.treesitter").select()
end)
-- Linewise.
vim.keymap.set({ "n", "x", "o" }, "gA", 'V<cmd>lua require("leap.treesitter").select()<cr>')

M.core = {
  ["n|<Tab>"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent():with_desc("goto next buffer"),
  ["n|<S-Tab>"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent():with_desc("goto prev buffer"),

  ["n|Y"] = map_cmd("y$"):with_desc("editn: Yank text to EOL"),
  ["n|D"] = map_cmd("d$"):with_desc("editn: Delete text to EOL"),
  -- ["n|n"] = map_cmd("nzzzv"):with_noremap():with_desc("editn: Next search result"),
  -- ["n|N"] = map_cmd("Nzzzv"):with_noremap():with_desc("editn: Prev search result"),
  ["n|<C-h>"] = map_cmd("<C-w>h"):with_noremap():with_desc("window: Focus left"),
  ["n|<C-l>"] = map_cmd("<C-w>l"):with_noremap():with_desc("window: Focus right"),
  ["n|<C-j>"] = map_cmd("<C-w>j"):with_noremap():with_desc("window: Focus down"),
  ["n|<C-k>"] = map_cmd("<C-w>k"):with_noremap():with_desc("window: Focus up"),
  -- Insert mode
  ["i|<C-u>"] = map_cmd("<C-G>u<C-U>"):with_noremap():with_desc("editi: Delete previous block"),
  ["i|<C-b>"] = map_cmd("<Left>"):with_noremap():with_desc("editi: Move cursor to left"),
  ["i|<C-a>"] = map_cmd("<ESC>^i"):with_noremap():with_desc("editi: Move cursor to line start"),
  -- Command mode
  ["c|<C-b>"] = map_cmd("<Left>"):with_noremap():with_desc("editc: Left"),
  ["c|<C-f>"] = map_cmd("<Right>"):with_noremap():with_desc("editc: Right"),
  ["c|<C-a>"] = map_cmd("<Home>"):with_noremap():with_desc("editc: Home"),
  ["c|<C-e>"] = map_cmd("<End>"):with_noremap():with_desc("editc: End"),
  ["c|<C-d>"] = map_cmd("<Del>"):with_noremap():with_desc("editc: Delete"),
  ["c|<C-h>"] = map_cmd("<BS>"):with_noremap():with_desc("editc: Backspace"),
  ["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap():with_desc("editc: Complete path of current file"),
  -- Visual mode
  ["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):with_desc("editv: Move this line down"),
  ["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):with_desc("editv: Move this line up"),
  ["v|<"] = map_cmd("<gv"):with_desc("editv: Decrease indent"),
  ["v|>"] = map_cmd(">gv"):with_desc("editv: Increase indent"),
}

M.basic = {

  -- Plugin: auto_session
  -- ["n|<leader>ss"] = map_cu("SaveSession"):with_noremap():with_silent():with_desc("session: Save"),
  -- ["n|<leader>sr"] = map_cu("RestoreSession"):with_noremap():with_silent():with_desc("session: Restore"),
  -- ["n|<leader>sd"] = map_cu("DeleteSession"):with_noremap():with_silent():with_desc("session: Delete"),

  -- Plugin: clever-f
  ["n|;"] = map_callback(function()
    return et("<Plug>(clever-f-repeat-forward)")
  end):with_expr(),

  -- Plugin: comment.nvim
  ["n|,/"] = map_callback(function()
      require("Comment.api").toggle.linewise.current()
    end)
    :with_silent()
    :with_noremap()
    :with_desc("edit: toggle line-comments"),
  ["v|,/"] = map_cmd("<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>"):with_silent():with_noremap():with_desc("edit: toggle selected line-comments"),

  -- Plugin: vim-easy-align
  --["n|gea"] = map_callback(function()
  --		return et("<Plug>(EasyAlign)")
  --	end)
  --	:with_expr()
  --	:with_desc("edit: Align with delimiter"),
  --["x|gea"] = map_callback(function()
  --		return et("<Plug>(EasyAlign)")
  --	end)
  --	:with_expr()
  --	:with_desc("edit: Align with delimiter"),

  ["n|,w"] = map_cu("Telescope grep_string"):with_noremap():with_silent():with_desc("find: Current word"),
  -- Plugin: hop
  ["n|gw"] = map_cu("HopWord"):with_noremap():with_desc("jump: Goto word"),
  ["v|gw"] = map_callback(function()
    require("hop").hint_words()
  end):with_desc("select range to a word by hop jump"),
  ["n|gl"] = map_cu("HopLine"):with_noremap():with_desc("jump: Goto line"),
  ["vn|gs"] = map_callback(function()
    require("hop").hint_char2()
  end):with_desc("jump in all windows"),
  ["n|s"] = map_callback(function()
    require("leap").leap({
      target_windows = require("leap.user").get_focusable_windows(),
    })
  end):with_desc("leap jump in all windows"),

  -- Plugin: nvim-treehopper
  -- o: Operator-pending mode. 先按了操作，进入等待范围选择，比如 y(复制),d(删除),c(修改)
  --    这是因为vim是先输入要做的操作，再输入范围。
  ["o|m"] = map_cu("lua require('tsht').nodes()"):with_silent():with_desc("Operator-pending: motion syntax tree"),
  -- xnoremap <silent> m :lua require('tsht').nodes()<CR>
  ["n|gm"] = map_cu("lua require('tsht').nodes()"):with_silent():with_desc("visual select with motion syntax tree"),

  -- Plugin: nvim-tree
  ["n|<leader>e"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent():with_desc("nvim-tree: Find file"),
  -- Focus 和 FindFile 在没有auto change root等配置时是等价的
  --["n|<leader>e"] = map_cr("NvimTreeFocus"):with_noremap():with_silent():with_desc("nvim-tree: focus"),

  -- Plugin: sniprun
  --["v|<leader>r"] = map_cr("SnipRun"):with_noremap():with_silent():with_desc("tool: Run code by range"),
  --["n|<leader>r"] = map_cu([[%SnipRun]]):with_noremap():with_silent():with_desc("tool: Run code by file"),

  -- Plugin: toggleterm
  ["t|<Esc><Esc>"] = map_cmd([[<C-\><C-n>]]):with_noremap():with_silent(),
  ["n|<A-i>"] = map_cr([[execute v:count . "ToggleTerm direction=float"]]):with_noremap():with_silent():with_desc("terminal: Toggle float"),
  ["i|<A-i>"] = map_cmd("<Esc><Cmd>ToggleTerm direction=float<CR>"):with_noremap():with_silent():with_desc("terminal: Toggle float"),
  ["t|<A-i>"] = map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent():with_desc("terminal: Toggle float"),

  -- Plugin: trouble
  --["n|gt"] = map_cr("TroubleToggle"):with_noremap():with_silent():with_desc("lsp: Toggle trouble list"),
  -- ["n|<leader>r"] = map_cr("Trouble lsp_references"):with_noremap():with_silent():with_desc("lsp: Show lsp references"),
  ["n|,d"] = map_cr("Trouble diagnostics"):with_noremap():with_silent():with_desc("lsp: Show document diagnostics"),

  -- ["n|<leader>tq"] = map_cr("Trouble quickfix")
  -- 	:with_noremap()
  -- 	:with_silent()
  -- 	:with_desc("lsp: Show quickfix list"),
  -- ["n|<leader>tl"] = map_cr("Trouble loclist"):with_noremap():with_silent():with_desc("lsp: Show loclist"),

  -- Plugin: telescope
  -- ["n|<leader>fc"] = map_cmd("<Cmd>Telescope commands<CR>"):with_silent():with_desc("tool: Toggle commands panel"),
  ["n|<leader>m"] = map_callback(function()
      -- command panel
      require("telescope.builtin").keymaps({
        lhs_filter = function(lhs)
          return not string.find(lhs, "Þ")
        end,
        layout_config = {
          width = 0.6,
          height = 0.7,
          prompt_position = "top",
        },
      })
    end)
    :with_noremap()
    :with_silent()
    :with_desc("tool: Toggle key-map command panel"),
  ["n|<leader>u"] = map_callback(function()
      require("telescope").extensions.undo.undo()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("edit: Show undo history"),
  ["n|<leader>w"] = map_callback(function()
      require("telescope").extensions.live_grep_args.live_grep_args()
    end)
    :with_noremap()
    :with_silent()
    :with_desc("find: Word in project"),
  ["n|<leader>n"] = map_cu(":enew"):with_noremap():with_silent():with_desc("buffer: New"),
  ["n|<leader>f"] = map_cu("Telescope find_files previewer=false"):with_noremap():with_silent():with_desc("find: File in project"),
  ["n|<leader>z"] = map_cu("Telescope zoxide list"):with_noremap():with_silent():with_desc("edit: Change current direrctory by zoxide"),
  ["n|<leader>b"] = map_cu("Telescope buffers previewer=false"):with_noremap():with_silent():with_desc("find: Buffer opened"),
  ["n|<leader>j"] = map_cu("Telescope jumplist previewer=false"):with_noremap():with_silent():with_desc("show jumplist"),
  ["n|<leader>t"] = map_cu("Telescope tagstack previewer=false"):with_noremap():with_silent():with_desc("show tagstack"),
  ["n|<leader>q"] = map_cu("exit"):with_noremap():with_silent():with_desc("exit"),
  ["n|<leader>d"] = map_cu("Bdelete"):with_desc("delete current buffer"),
}

M.buf = function(buf)
  local plug_map = {
    -- LSP-related keymaps, work only when event = { "InsertEnter", "LspStart" }
    ["n|<leader>o"] = map_cr("Lspsaga outline"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Toggle outline"),
    --["n|g["] = map_cr("Lspsaga diagnostic_jump_prev"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Prev diagnostic"),
    --["n|g]"] = map_cr("Lspsaga diagnostic_jump_next"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Next diagnostic"),
    -- ["n|<leader>sl"] = map_cr("Lspsaga show_line_diagnostics"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Line diagnostic"),
    ["n|ge"] = map_cr("Lspsaga show_cursor_diagnostics"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Cursor diagnostic"),
    ["n|,s"] = map_callback(function()
        vim.lsp.buf.signature_help()
      end)
      :with_noremap()
      :with_silent()
      :with_desc("lsp: Signature help"),
    ["n|,r"] = map_cr("Lspsaga rename"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Rename in file range"),
    ["n|,R"] = map_cr("Lspsaga rename ++project"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Rename in project range"),
    -- ["n|K"] = map_cr("Lspsaga hover_doc"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Show doc"),
    ["n|K"] = map_callback(function()
        if vim.bo.filetype == "haskell" then
          vim.lsp.buf.hover() -- native doc popup renders link correct.
        else
          vim.cmd(":Lspsaga hover_doc")
        end
      end)
      :with_noremap()
      :with_silent()
      :with_desc("lsp: Show doc"),
    ["nv|,a"] = map_cr("Lspsaga code_action"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Code action for cursor"),
    ["n|gD"] = map_cr("Lspsaga peek_definition"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Preview definition"),
    ["n|gd"] = map_cr("Lspsaga goto_definition"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Goto definition"),
    ["n|gr"] = map_cr("Lspsaga finder"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Show reference"),
    ["n|gI"] = map_cr("Lspsaga incoming_calls"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Show all incoming calls on the cursor symbol"),
    ["n|go"] = map_cr("Lspsaga outgoing_calls"):with_buffer(buf):with_noremap():with_silent():with_desc("lsp: Show outgoing calls"),
  }

  return plug_map
  -- bind.nvim_load_mapping(plug_map)
end

return M
