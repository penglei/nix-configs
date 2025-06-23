if vim.g.vscode then
	vim.opt.clipboard = "unnamed"
	return
end

function _G.put(...)
	local objects = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		table.insert(objects, vim.inspect(v))
	end

	print(table.concat(objects, "\n"))
	return ...
end

vim.log.level = vim.log.levels.WARN

-- mini setup
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- mini.deps base setup
require("mini.deps").setup({ path = { package = path_package } })

require("config.entry")

-- vim.notify(vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_get_current_buf() }))
