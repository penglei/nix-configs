-- 把 yank 内容送到系统剪贴板的工具。
--
-- 不在每次 yank 时自动触发；由用户手动按 Y 调用（见 keymaps/default.lua 的 v|Y）。
-- 原因：本地不想被其他 clipboard manager 监听系统剪贴板，所以默认
-- `vim.opt.clipboard` 不开 unnamedplus（见 options.lua），由这个
-- 手动 keymap 决定什么时候把 `"` 寄存器的内容送到系统剪贴板。
--
-- 通道选择由当前环境决定：
--   * 本地：写入 * 寄存器，由 X server / 终端写到系统剪贴板。
--   * 远端 SSH：通过 OSC52 终端转义序列送到本地终端剪贴板；
--     若在 tmux 内则用 passthrough 序列包装，避免被 tmux 拦截。
local M = {}

local function osc52(str)
	-- neovim 0.10+ 自带 vim.base64，不需要插件提供
	local b64 = vim.base64.encode(str)
	local seq
	if vim.env.TMUX then
		-- tmux passthrough 包装，避免序列被 tmux 拦截
		-- 需要远端 tmux 启用 `set -g allow-passthrough on`（tmux >=3.3a）
		seq = string.format("\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\", b64)
	else
		seq = string.format("\x1b]52;c;%s\x07", b64)
	end
	local bytes = vim.fn.chansend(vim.v.stderr, seq)
	vim.notify(string.format("[clip] %d chars sent via OSC52 (%d bytes)", #str, bytes))
end

function M.yank_to_system(str)
	if vim.env.SSH_CONNECTION then
		osc52(str)
	else
		vim.fn.setreg("*", str)
		vim.notify("Clipboard updated")
	end
end

return M
