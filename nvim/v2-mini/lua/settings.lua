--- api-based configuration
--- ==============================================================================

local util = require("config.util")

local autocmd = vim.api.nvim_create_autocmd
-- augroup is named autocmd

vim.filetype.add({
	extension = {
		["typst"] = "typst",
		["ncl"] = "nickel",
		["nkl"] = "nickel",
		["dhall"] = "dhall",
		["lalrpop"] = "lalrpop",

		["bxl"] = "bzl",
		["BUCK"] = "bzl",
		["TARGETS"] = "bzl", -- maybe detect it in project context?
	},
})

--[[
-- filetype resolving by nvim api
autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.ncl", "*.nkl" },
	group = bufferSettingAugroup,
	callback = function(event)
		-- vim.api.nvim_buf_set_option(event.buf, "filetype", "nickel") -- deprecated
		vim.api.nvim_set_option_value("filetype", "nickel", { buf = event.buf })
		-- vim.notify((vim.inspect(event)))  #why got BufReadPost?
	end,
})
--]]

-- auto close some filetype with <q>
autocmd("FileType", {
	pattern = {
		"alpha",
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
		"lspsagaoutline",
		"ministarter",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
	end,
})
autocmd("FileType", {
	pattern = "nickel",
	callback = function(event)
		vim.api.nvim_set_option_value("commentstring", "#%s", { buf = event.buf })
	end,
})

local bufferSettingAugroup = vim.api.nvim_create_augroup("BufferSetting", { clear = true })
autocmd("BufWritePre", {
	pattern = {
		"/tmp/**",
		"*.tmp",
		"*.bak",
		"COMMIT_EDITMSG",
		"MERGE_MSG",
	},
	group = bufferSettingAugroup,
	callback = function()
		vim.opt_local.undofile = false -- 设置当前缓冲区无 undo 文件
	end,
})

----------------- global key mapping -----------------
util.bind:new():load(require("config.keymaps.global"))

--------------- lsp buffer key mapping ---------------
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		util.bind:new(event.buf):load(require("config.keymaps.buffer"))
	end,
})

require("config")
