local setup = function(notify)
	vim.notify = function(msg, level)
		if type(msg) ~= "string" then msg = vim.inspect(msg) end
		notify(msg, level)
	end

	-- vim.notify("notify initialized", vim.log.levels.TRACE)
end

local make_mini_notify = function()
	require("mini.notify").setup()

	local level_config = { duration = 3000 }
	local opts = {}
	if vim.log.level <= vim.log.levels.DEBUG then opts.DEBUG = level_config end
	if vim.log.level <= vim.log.levels.TRACE then opts.TRACE = level_config end
	return require("mini.notify").make_notify(opts)
end

setup(make_mini_notify())
