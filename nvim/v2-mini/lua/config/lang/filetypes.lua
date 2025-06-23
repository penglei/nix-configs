local autocmd = vim.api.nvim_create_autocmd

local autocmd_filetype_option = function(pattern, callbak)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = pattern,
		callback = callbak,
	})
end

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

autocmd_filetype_option("lua", function(args)
	vim.bo[args.buf].expandtab = false
	vim.bo[args.buf].shiftwidth = 4
	vim.bo[args.buf].tabstop = 4
end)

autocmd_filetype_option({ "python", "javascript", "typescript" }, function(args)
	local indent = 2
	if args.match == "python" then indent = 4 end

	vim.bo[args.buf].expandtab = true
	vim.bo[args.buf].shiftwidth = indent
	vim.bo[args.buf].tabstop = indent
end)

autocmd_filetype_option("go", function(args)
	vim.bo[args.buf].expandtab = false
	vim.bo[args.buf].shiftwidth = 4
	vim.bo[args.buf].tabstop = 4
end)

autocmd("FileType", {
	pattern = "make",
	command = "setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4",
})

autocmd_filetype_option("nickel", function(event) vim.api.nvim_set_option_value("commentstring", "#%s", { buf = event.buf }) end)
