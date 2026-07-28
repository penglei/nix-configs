-- :WkDebug — 诊断并尝试恢复 which-key 触发器
--
-- 现象：单按 <leader> 偶发不弹提示面板，而是退化为空格的默认行为
-- （normal 模式下光标向前 1 字符）。重启 nvim 才能恢复。
--
-- 已知诱因：
-- 1. 宏录制模式（最常见）：用户误按 q + 寄存器键（如 qj）进入录宏，
--    which-key 在 RecordingEnter autocmd 里 Buf.clear 当前 buffer 的所有
--    触发器映射（包括 <leader>），并依赖 50ms 轮询 timer 重建。但
--    triggers.lua:147-149 在 in_macro() 为 true 时会一直推迟重建
--    （vim.defer_fn(M.schedule, 100)），所以录宏期间 <leader> 触发器
--    永远不会重新挂上，<leader> 退化为空格默认行为。
--    修复：按 q 停止录宏即可，which-key 会自动重新挂上触发器。
--
-- 2. LspAttach / LspDetach 时也会 Buf.clear，但通常 50ms timer 会快速
--    重建。若卡住，本命令的强制 Buf.clear + Buf.get 也能恢复。
--
-- 用法：出 bug 时执行 `:WkDebug`。它会把当时的映射状态、suspended 标志、
-- 当前 buffer 的 modes 全部打印出来，再尝试强制重建触发器。
-- 若重建后 <leader> 恢复，说明是触发器丢失；若不行，打印的信息能指引
-- 下一步排查方向。

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "WkDebug" })
end

-- 防误触录宏：用户原本想关 Outline/其他窗口，按 <C-l> 切窗口失败后焦点
-- 仍在 normal buffer，接着按 q 期望 `:q` 关窗口，却误入宏录制（q + 下一个
-- 键作为寄存器名）。一旦进入录制，which-key 会清空 <leader> 触发器并在
-- 录制期间停止重建，导致 <leader> 退化为空格默认行为，且很难察觉根因。
-- 这里在 RecordingEnter 时弹一个醒目的 WARN，让用户立刻发现并按 q 停录。
vim.api.nvim_create_autocmd("RecordingEnter", {
	group = vim.api.nvim_create_augroup("WkGuard", { clear = true }),
	callback = function()
		vim.notify(
			("Macro recording to @%s. Press q to stop. <leader> is disabled until then."):format(vim.fn.reg_recording()),
			vim.log.levels.WARN,
			{ title = "macro guard" }
		)
	end,
})

vim.api.nvim_create_user_command("WkDebug", function()
	local ok_wk, _ = pcall(require, "which-key")
	if not ok_wk then
		return notify("which-key not loaded")
	end

	local Buf = require("which-key.buf")
	local Triggers = require("which-key.triggers")
	local Util = require("which-key.util")

	local buf = vim.api.nvim_get_current_buf()
	local mode = Util.mapmode()

	local leader_key = vim.api.nvim_replace_termcodes("<leader>", true, true, true)
	local maparg = vim.fn.maparg(leader_key, mode, false, true)
	local leader_empty = vim.tbl_isempty(maparg)

	local recording = vim.fn.reg_recording()
	local executing = vim.fn.reg_executing()
	local in_macro = Util.in_macro()

	-- 仅统计与当前 buffer + mode 相关的触发器，避免把全量 _triggers 打印出来
	-- （_triggers 是 table<id, trigger>，id = buf:mode:keys）
	local buf_triggers = {}
	for _, t in pairs(Triggers._triggers) do
		if t.buf == buf and t.mode == mode then buf_triggers[#buf_triggers + 1] = t.keys end
	end
	local buf_has_leader = vim.tbl_contains(buf_triggers, leader_key)

	-- suspended_modes 的 key 是 wk.Mode 对象（table），直接 inspect 会爆到几 MB。
	-- 只取 mode 字段做摘要。
	local suspended_summary = {}
	for m, _ in pairs(Triggers.suspended) do
		suspended_summary[#suspended_summary + 1] = string.format("%s(buf=%d)", m.mode, m.buf.buf)
	end

	local info = {
		buf = buf,
		filetype = vim.bo[buf].filetype,
		buftype = vim.bo[buf].buftype,
		mapmode = mode,
		recording = recording,
		executing = executing,
		in_macro = in_macro,
		suspended = suspended_summary,
		buf_trigger_count = #buf_triggers,
		buf_has_leader_trigger = buf_has_leader,
		leader_maparg_empty = leader_empty,
	}

	-- 1. 录宏是首要嫌疑：给最显眼的提示
	if in_macro then
		local reg = recording ~= "" and recording or executing
		notify(
			("当前处于宏录制/回放状态（register=%s），which-key 已主动停用 <leader> 触发器。\n"
				.. "按 `q` 停止录制即可恢复，无需重启 nvim。"):format(reg),
			vim.log.levels.WARN
		)
	end

	-- 2. 强制重建触发器：先 clear，再 Buf.get() 走 Mode.new/update/attach
	pcall(function()
		Buf.clear({ buf = buf })
		Buf.get({ buf = buf, update = true })
	end)

	-- 重建后再统计一次
	local buf_triggers_after = {}
	for _, t in pairs(Triggers._triggers) do
		if t.buf == buf and t.mode == mode then buf_triggers_after[#buf_triggers_after + 1] = t.keys end
	end
	local buf_has_leader_after = vim.tbl_contains(buf_triggers_after, leader_key)

	local after = {
		buf_trigger_count_after = #buf_triggers_after,
		buf_has_leader_trigger_after = buf_has_leader_after,
	}

	notify(vim.inspect({ info = info, after_clear = after }))

	-- 3. 若重建后 <leader> 触发器仍未挂上，明确提示
	if not buf_has_leader_after and not in_macro then
		notify(
			"重建后 <leader> 触发器仍未挂上，且不在录宏状态。"
				.. "可能是 which-key 的 Mode:attach 未把 <leader> 视为安全节点（is_safe 检查）。"
				.. "请把 info 完整内容贴出来进一步分析。",
			vim.log.levels.WARN
		)
	end
end, { desc = "Diagnose & rebuild which-key triggers for current buffer" })
