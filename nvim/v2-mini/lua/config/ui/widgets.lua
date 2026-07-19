-- require("mini.git").setup()
require("mini.trailspace").setup()

--- https://github.com/catgoose/nvim-colorizer.lua
require("colorizer").setup({
	filetypes = {
		"html",
		"css",
		"javascript",
		html = { mode = "foreground" },
	},
	-- Use `user_default_options` as the second parameter, which uses `background`
	-- for every mode. This is the inverse of the previous setup configuration.
	user_default_options = { mode = "background" },
})

require("tiny-inline-diagnostic").setup({
	multilines = {
		enabled = true,
	},
	show_all_diags_on_cursorline = true,
})
require("lsp_lines").setup()
-- lsp_lines need disable diagnostic virtual text
vim.diagnostic.config({
	virtual_text = false,
})

-- Work around nvim 0.12.4 underline handler crash on stale diagnostics
-- (e.g. when opening a file via snacks picker that LSP sent publishDiagnostics
-- for while the buffer was still unloaded). See lua/config/ui/diagnostic_underline.lua.
require("config.ui.diagnostic_underline")

require("inline_git_blame").setup({
	-- excluded_filetypes will be extended from default
	excluded_filetypes = { "NvimTree", "neo-tree", "TelescopePrompt", "help" },
	debounce_ms = 150,
	autocmd = false, -- config in toggle
})

-- Monkey-patch nvim_buf_set_extmark for the "inline_blame" namespace only,
-- to guard against stale buffers/lines. The inline_git_blame plugin runs
-- `git blame` via jobstart and then defers its internal `show_blame` with
-- vim.schedule. If the buffer is wiped (e.g. <space>x) or shrunk in between,
-- the deferred set_extmark raises "Invalid 'line': out of range".
--
-- `show_blame` is a `local function` in the plugin source, so we can't replace
-- it directly. Instead, intercept the only API it ultimately calls and no-op
-- when the target buffer/line is no longer valid. Scoped to the inline_blame
-- namespace so other plugins are untouched. mini.deps upgrades of this plugin
-- don't reset our patch since we patch the global vim.api method.
do
	local blame_ns = vim.api.nvim_create_namespace("inline_blame")
	local orig_set_extmark = vim.api.nvim_buf_set_extmark
	vim.api.nvim_buf_set_extmark = function(bufnr, ns, line, col, opts)
		if ns == blame_ns then
			if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return 0 end
			if type(line) ~= "number" or line < 0 then return 0 end
			local ok, count = pcall(vim.api.nvim_buf_line_count, bufnr)
			if not ok or line >= count then return 0 end
		end
		return orig_set_extmark(bufnr, ns, line, col, opts)
	end
end

------------------------------------------------
-- vim.lsp.handlers["$/progress"] = function() end -- disable progress notification
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
		if not client or type(value) ~= "table" then return end
		local p = progress[client.id]

		for i = 1, #p + 1 do
			if i == #p + 1 or p[i].token == ev.data.params.token then
				p[i] = {
					token = ev.data.params.token,
					msg = ("[%3d%%] %s%s"):format(
						value.kind == "end" and 100 or value.percentage or 100,
						value.title or "",
						value.message and (" **%s**"):format(value.message) or ""
					),
					done = value.kind == "end",
				}
				break
			end
		end

		local msg = {} ---@type string[]
		progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)

		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		vim.notify(table.concat(msg, "\n"), vim.log.levels.WARN, {
			id = "lsp_progress",
			title = client.name,
			opts = function(notif)
				notif.icon = #progress[client.id] == 0 and " " or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
			end,
		})
	end,
})

-- https://github.com/RRethy/vim-illuminate?tab=readme-ov-file#configuration
require("illuminate").configure({
	delay = 200,
	disable_keymaps = false,
})

--[[
local animate = require("mini.animate")
animate.setup({
	resize = {
		enable = false,
	},
	scroll = {
		timing = animate.gen_timing.cubic({ duration = 120, unit = "total" }),
	},
	cursor = {
		timing = animate.gen_timing.cubic({ duration = 100, unit = "total" }),
	},
})
--]]

-- -- Prompts the yank scope
-- vim.api.nvim_create_autocmd("TextYankPost", {
-- 	pattern = "*",
-- 	command = [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
-- })

require("tiny-glimmer").setup({
	hijack_ft_disabled = require("config.notfiles"),
	overwrite = {
		undo = { enabled = true },
		redo = { enabled = true },
	},
})

require("todo-comments").setup()
