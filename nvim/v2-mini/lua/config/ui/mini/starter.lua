-- https://github.com/echasnovski/mini.nvim/discussions/36

local headers = {
	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠐⠐⠐⠐⠐⠐⡠⠀⢄⠠⠀⡄⠠⢀⠄⠠⡀⠄⡄⢀⠄⠠⡀⠄⢠⠀⠄⠂⠐⠐⠐⠐⠐⠐]],
	[[⠄⠄⠄⠄⠄⠄⠄⢀⣀⣤⣤⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣄⣀⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠠⣿⢿⣿⢿⣯⣿⣽⢯⣟⡿⣽⢯⣿⣽⣯⣿⣽⣟⣟⣗⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⢸⡻⠟⡚⡛⠚⠺⢟⣿⣗⣿⢽⡿⡻⠇⠓⠓⠓⠫⢷⢳⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⢼⡺⡽⣟⡿⣿⣦⡀⡈⣫⣿⡏⠁⢀⣰⣾⢿⣟⢟⢮⢱⡀⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⣳⠑⠝⠌⠊⠃⠃⢏⢆⣺⣿⣧⢘⠎⠋⠊⠑⠨⠣⠑⣕⠂⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⢷⣿⣯⣦⣶⣶⣶⡶⡯⣿⣿⡯⣟⣶⣶⣶⣶⣦⣧⣷⣾⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⢹⢻⢯⢟⣟⢿⢯⢿⡽⣯⣿⡯⣗⡿⡽⡯⣟⡯⣟⠯⡻⠂⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠢⡑⡑⠝⠜⣑⣭⠻⢝⠿⡿⡯⠫⠯⣭⣊⠪⢊⠢⢑⠰⠁⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠈⢹⣔⡘⢿⣿⣿⣶⠄⠁⠑⠈⠠⣵⣿⡿⡯⠂⣠⡞⡈⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠄⠨⢻⡆⢄⣀⢩⠄⠄⠴⠕⠄⠄⠈⠉⣀⠠⢢⡟⢌⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠄⠈⠐⡝⣧⠈⡉⡙⢛⠛⠛⠛⠛⢋⠉⡀⡼⠩⡂⠁⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠪⡻⣔⣮⣷⡆⠄⢰⣿⢦⣣⢞⠅⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠓⣷⣿⡅⠄⢸⣿⡗⠇⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[⠂⠄⡁⠂⠄⢄⡁⠂⠄⡁⠂⠄⠡⢈⠐⠠⠈⠄⡁⠂⠌⠠⢁⠂⡐⠠⢈⠌⠠⢁⠂⡐⠠⢄]],
	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
	[[   ~~~~ HASTE MAKES WASTE ~~~~    ]],
}
local header = headers[#headers] -- table.concat(headers, "\n")

local starter = require("mini.starter")

-- A workaround to centralize everything.
-- `aligning("center", "center")` will centralize the longest line in
-- `content`, then left align other items to its beginning.
-- It causes the header to not be truly centralized and have a variable
-- shift to the left.
-- This function will use `aligning` and pad the header accordingly.
-- It also goes over `justified_sections`, goes over all their items names
-- and justifies them by padding existing space in them.
-- Since `item_bullet` are separated from the items themselves, their
-- width is measured separately and deducted from the padding.
local centralize = function(justified_sections, centralize_header)
	return function(content, buf_id)
		-- Get max line width, same as in `aligning`
		local max_line_width = math.max(unpack(vim.tbl_map(function(l) return vim.fn.strdisplaywidth(l) end, starter.content_to_lines(content))))

		-- Align
		content = starter.gen_hook.aligning("center", "center")(content, buf_id)

		-- Iterate over header items and pad with relative missing spaces
		if centralize_header == true then
			local coords = starter.content_coords(content, "header")
			for _, c in ipairs(coords) do
				local unit = content[c.line][c.unit]
				local pad = (max_line_width - vim.fn.strdisplaywidth(unit.string)) / 2
				if unit.string ~= "" then unit.string = string.rep(" ", pad) .. unit.string end
			end
		end

		-- Justify recent files and workspaces
		if justified_sections ~= nil and #justified_sections > 0 then
			-- Check if `adding_bullet` has mutated the `content`
			local coords = starter.content_coords(content, "item_bullet")
			local bullet_len = 0
			if coords ~= nil then
				-- Bullet items are defined, compensate for bullet prefix width
				bullet_len = vim.fn.strdisplaywidth(content[coords[1].line][coords[1].unit].string)
			end

			coords = starter.content_coords(content, "item")
			for _, c in ipairs(coords) do
				local unit = content[c.line][c.unit]
				if vim.tbl_contains(justified_sections, unit.item.section) then
					local one, two = unpack(vim.split(unit.string, " "))
					unit.string = one .. string.rep(" ", max_line_width - vim.fn.strdisplaywidth(unit.string) - bullet_len + 1) .. two
				end
			end
		end
		return content
	end
end

local M = {}

-- 自定义starter 的按键配置
function M.setup_ministarter_mappings(bufnr)
	--  连按两次<Esc>退出 ministarter ( 按一次Esc是清空Query )
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc><Esc>", "<CMD>q<CR>", { silent = true, noremap = true, nowait = false })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Tab>", "", {
		callback = function() starter.update_current_item("next") end,
	})
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<S-Tab>", "", {
		callback = function() starter.update_current_item("previous") end,
	})
end

-- 检查当前window buffer 并设置退出按键。
-- 这是一个比较朴素的实现，starter支持在多窗口中显示，
-- 健壮的做法应该检查所有windows并设置key mapping。
function M.check_to_mapping()
	local bufnr = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
	if filetype == "ministarter" then
		M.setup_ministarter_mappings(bufnr)
		return true
	end
	return false
end

-- init 用于额外配置ministarter
function M.init()
	local group = vim.api.nvim_create_augroup("MinistarterKeymap", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			-- vim.notify(vim.inspect(event), vim.log.levels.INFO)

			vim.defer_fn(function() -- 延迟执行等待插件加载完成
				local ok = M.check_to_mapping()
				if ok then return end

				-- vim.notify("new timer", vim.log.levels.INFO)
				local timer = vim.loop.new_timer()
				local count = 0 -- max count
				timer:start(
					0,
					1000,
					vim.schedule_wrap(function()
						-- vim.notify("timer running", vim.log.levels.INFO)
						if count > 5 or M.check_to_mapping() then
							timer:stop()
							timer:close()
						else
							count = count + 1
						end
					end)
				)
			end, 300) -- 延迟300ms
		end,
	})
end

M.init()

starter.setup({
	header = header,
	items = {
		{
			name = "Recent files",
			action = function() require("mini.extra").pickers.oldfiles() end,
			section = "Entry",
		},
		{
			name = "Find files",
			action = function() vim.cmd([[Pick files]]) end,
			section = "Entry",
		},
		starter.sections.recent_files(10, false, function(path)
			-- Bring back trailing slash after `dirname`
			return " " .. vim.fn.fnamemodify(path, ":~:.:h") .. "/"
		end),
		starter.sections.builtin_actions(),
	},
	query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.",
	content_hooks = {
		starter.gen_hook.adding_bullet(),
		centralize({ "Recent files" }, true),
	},
	autoopen = true,
})
