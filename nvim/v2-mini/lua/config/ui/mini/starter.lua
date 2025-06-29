-- local header = table.concat({
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠐⠐⠐⠐⠐⠐⡠⠀⢄⠠⠀⡄⠠⢀⠄⠠⡀⠄⡄⢀⠄⠠⡀⠄⢠⠀⠄⠂⠐⠐⠐⠐⠐⠐]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⢀⣀⣤⣤⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣄⣀⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠠⣿⢿⣿⢿⣯⣿⣽⢯⣟⡿⣽⢯⣿⣽⣯⣿⣽⣟⣟⣗⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⢸⡻⠟⡚⡛⠚⠺⢟⣿⣗⣿⢽⡿⡻⠇⠓⠓⠓⠫⢷⢳⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⢼⡺⡽⣟⡿⣿⣦⡀⡈⣫⣿⡏⠁⢀⣰⣾⢿⣟⢟⢮⢱⡀⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⣳⠑⠝⠌⠊⠃⠃⢏⢆⣺⣿⣧⢘⠎⠋⠊⠑⠨⠣⠑⣕⠂⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⢷⣿⣯⣦⣶⣶⣶⡶⡯⣿⣿⡯⣟⣶⣶⣶⣶⣦⣧⣷⣾⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⢹⢻⢯⢟⣟⢿⢯⢿⡽⣯⣿⡯⣗⡿⡽⡯⣟⡯⣟⠯⡻⠂⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠢⡑⡑⠝⠜⣑⣭⠻⢝⠿⡿⡯⠫⠯⣭⣊⠪⢊⠢⢑⠰⠁⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠈⢹⣔⡘⢿⣿⣿⣶⠄⠁⠑⠈⠠⣵⣿⡿⡯⠂⣠⡞⡈⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠨⢻⡆⢄⣀⢩⠄⠄⠴⠕⠄⠄⠈⠉⣀⠠⢢⡟⢌⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠈⠐⡝⣧⠈⡉⡙⢛⠛⠛⠛⠛⢋⠉⡀⡼⠩⡂⠁⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠪⡻⣔⣮⣷⡆⠄⢰⣿⢦⣣⢞⠅⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠓⣷⣿⡅⠄⢸⣿⡗⠇⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[⠂⠄⡁⠂⠄⢄⡁⠂⠄⡁⠂⠄⠡⢈⠐⠠⠈⠄⡁⠂⠌⠠⢁⠂⡐⠠⢈⠌⠠⢁⠂⡐⠠⢄]],
-- 	[[⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄]],
-- 	[[   ~~~~ HASTE MAKES WASTE ~~~~    ]],
-- }, "\n")

local header = [[   ~~~~ HASTE MAKES WASTE ~~~~    ]]

local starter_custom = function()
	return {
		{
			name = "Recent Files",
			action = function()
				require("mini.extra").pickers.oldfiles()
			end,
			section = "Search",
		},
		-- {
		-- 	name = "Session",
		-- 	action = function()
		-- 		require("mini.sessions").select()
		-- 	end,
		-- 	section = "Search",
		-- },
	}
end

local M = {}

-- 自定义starter 的按键配置
function M.setup_ministarter_mappings(bufnr)
	--  连按两次<Esc>退出 ministarter ( 按一次Esc是清空Query )
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<Esc><Esc>",
		"<CMD>q<CR>",
		{ silent = true, noremap = true, nowait = false }
	)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Tab>", "", {
		callback = function()
			require("mini.starter").update_current_item("next")
		end,
	})
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<S-Tab>", "", {
		callback = function()
			require("mini.starter").update_current_item("previous")
		end,
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
				if ok then
					return
				end

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

require("mini.starter").setup({
	items = {
		starter_custom,
		require("mini.starter").sections.recent_files(5, false, false),
		require("mini.starter").sections.recent_files(5, true, false),
		-- require("mini.starter").sections.sessions(5, true),
	},
	autoopen = true,
	header = header,
	query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.",
})
