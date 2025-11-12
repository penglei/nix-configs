require("config.options")

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

-- create a command  BufDelete to delete current buffer without closing window

autocmd("VimEnter", {
	callback = function()
		vim.api.nvim_create_user_command("BufDelete", function(opts) Snacks.bufdelete() end, {
			desc = "Delete buffer without closing window",
		})
	end,
})

----------------- default key mapping -----------------
util.bind:new():load(require("config.keymaps.default"))

--------------- lsp buffer key mapping ---------------
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event) util.bind:new(event.buf):load(require("config.keymaps.lsp")) end,
})

-- TODO
-- mark all cursor before enter visual mode. https://github.com/kamalsacranie/nvim-mapper

require("config.plugins")
