require("mini.git").setup()
require("mini.trailspace").setup()

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

-- Prompts the yank scope
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
})

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

require("lsp_lines").setup()
-- lsp_lines need disable diagnostic virtual text
vim.diagnostic.config({
	virtual_text = false,
})

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
