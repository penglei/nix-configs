local MiniStatusline = require("mini.statusline")
local icons = require("config.ui.icons")
local keyboard_icon = icons.get("ui").Keyboard

-- 覆盖默认 section_mode：录制宏时把状态栏左侧的大 mode 色块文字替换为
-- "REC●j"（REC + 红色实心圆 + 寄存器名），并换成自定义红色背景 hl。
-- "REC●j" 长度 5 字符（● 为双宽，视觉占位接近 6 字符），与 "Normal"（6）
-- 基本等长，避免状态栏宽度跳动。红色背景 + 白色加粗文字非常醒目。
local orig_section_mode = MiniStatusline.section_mode
MiniStatusline.section_mode = function(args)
	local mode, mode_hl = orig_section_mode(args)
	local reg = vim.fn.reg_recording()
	if reg ~= "" then
		mode = "REC● " .. reg
		mode_hl = "StatusLineRecord"
	end
	return mode, mode_hl
end

-- 定义红色背景 hl group：前景保持白/亮色以保证可读性，背景用红色。
-- 在 catppuccin 加载后定义（catppuccin 在 plugins.lua 的 now() 块里 setup，
-- 早于此文件），并监听 ColorScheme 以防用户切换配色后丢失。
vim.api.nvim_set_hl(0, "StatusLineRecord", { fg = "#ffffff", bg = "#ff5555", bold = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("StatusLineRecordHl", { clear = true }),
	callback = function()
		vim.api.nvim_set_hl(0, "StatusLineRecord", { fg = "#ffffff", bg = "#ff5555", bold = true })
	end,
})

local statusline_active = function()
	local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
	local git = MiniStatusline.section_git({ trunc_width = 40 })
	local diff = MiniStatusline.section_diff({ trunc_width = 75 })
	local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
	local filename = MiniStatusline.section_filename({ trunc_width = 140 })
	local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
	local location = MiniStatusline.section_location({ trunc_width = 75 })
	local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

	local screenkey = function() return require("screenkey").get_keys() end

	-- Usage of `MiniStatusline.combine_groups()` ensures highlighting and
	-- correct padding with spaces between groups (accounts for 'missing'
	-- sections, etc.)
	return MiniStatusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
		"%<", -- Mark general truncate point
		{ hl = "MiniStatuslineFilename", strings = { filename } },
		"%=", -- End left alignment
		{ hl = "MiniStatuslineFileinfo", strings = { fileinfo, keyboard_icon, screenkey() } },
		{ hl = mode_hl, strings = { search, location } },
	})
end

require("screenkey").setup({
	-- win_opts = {
	-- 	relative = "editor",
	-- 	col = vim.o.columns / 2 - 20,
	-- 	title = "",
	-- 	anchor = "SW",
	-- 	width = 40,
	-- 	height = 1,
	-- },
})
require("screenkey").toggle_statusline_component()

vim.api.nvim_create_autocmd("User", {
	pattern = "ScreenkeyCleared",
	callback = function() vim.cmd("redrawstatus") end,
})

MiniStatusline.setup({
	content = {
		active = statusline_active,
	},
})

-- 录制状态切换时强制重绘状态栏，确保 REC@reg 及时出现/消失
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	group = vim.api.nvim_create_augroup("StatuslineRecording", { clear = true }),
	callback = function() vim.cmd("redrawstatus") end,
})
