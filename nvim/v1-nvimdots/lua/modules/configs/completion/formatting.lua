-- 这个模块是一个简易的通过lsp的format能力实现的自动format功能。也就是说没有lsp的语言，或者lsp不支持format则无法工作。
--[[
https://www.reddit.com/r/neovim/comments/13sdxep/how_to_setup_formatter_for_python/

> There is a fundamental difference between formatters and lsp. Lsp-zero just set's up lsp. Lsp is the language server protocol, so lsp-zero only setus up things you get from your lsp server, in python's case perhaps pyright. So formatting will only work if your language server supports it, hence why it's working for you in c and c++ files. In c and c++, clangd supports formatting, however in python's case and pyright it doesn't.

> It's quite common that the language server you use for completions, go to definition and etc might not support formatting or you prefer a formatter binary. For example black. black is just a simple command line utility, it doesn't implement the lsp protocol or anything so it's fundamentally different from language servers.

> However you can see that it would be quite cool to allow simple binaries like `black` or eslint to hook into the lsp and allow us to run formatting as if they were an lsp server. This is precisely why null-ls exists. Null-ls allows your simple binaries to hook into lsp features all
--]]

local M = {}

local disabled_workspaces = {}
local server_formatting_block_list = { clangd = true }

vim.api.nvim_create_user_command("FormatToggle", function()
	M.toggle_format_on_save()
end, {})

local block_list = {}

vim.api.nvim_create_user_command("FormatterToggleFt", function(opts)
	if block_list[opts.args] == nil then
		vim.notify(
			string.format("[LSP] Formatter for [%s] has been recorded in list and disabled.", opts.args),
			vim.log.levels.WARN,
			{ title = "LSP Formatter Warning" }
		)
		block_list[opts.args] = true
	else
		block_list[opts.args] = not block_list[opts.args]
		vim.notify(
			string.format(
				"[LSP] Formatter for [%s] has been %s.",
				opts.args,
				not block_list[opts.args] and "enabled" or "disabled"
			),
			not block_list[opts.args] and vim.log.levels.INFO or vim.log.levels.WARN,
			{ title = string.format("LSP Formatter %s", not block_list[opts.args] and "Info" or "Warning") }
		)
	end
end, { nargs = 1, complete = "filetype" })

function M.enable_format_on_save(is_configured)
	local opts = { pattern = "*", timeout = 1000 }
	vim.api.nvim_create_augroup("format_on_save", {})
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = "format_on_save",
		pattern = opts.pattern,
		callback = function()
			M.do_format({
				timeout_ms = opts.timeout,
				filter = M.format_filter,
			})
		end,
	})
	if not is_configured then
		vim.notify(
			"Successfully enabled format-on-save",
			vim.log.levels.INFO,
			{ title = "Settings modification success" }
		)
	end
end

function M.disable_format_on_save(is_configured)
	pcall(vim.api.nvim_del_augroup_by_name, "format_on_save")
	if not is_configured then
		vim.notify(
			"Successfully disabled format-on-save",
			vim.log.levels.INFO,
			{ title = "Settings modification success" }
		)
	end
end

function M.configure_format_on_save()
	M.enable_format_on_save(true)
end

function M.toggle_format_on_save()
	local status = pcall(vim.api.nvim_get_autocmds, {
		group = "format_on_save",
		event = "BufWritePre",
	})
	if not status then
		M.enable_format_on_save(false)
	else
		M.disable_format_on_save(false)
	end
end

function M.format_filter(clients)
	return vim.tbl_filter(function(client)
		local status_ok, formatting_supported = pcall(function()
			return client.supports_method("textDocument/formatting")
		end)
		if not server_formatting_block_list[client.name] and status_ok and formatting_supported then
			return client.name
		end
	end, clients)
end

function M.do_format(opts)
	local cwd = vim.fn.getcwd()
	for i = 1, #disabled_workspaces do
		if cwd.find(cwd, disabled_workspaces[i]) ~= nil then
			vim.notify(
				string.format("[LSP] Formatting support for all files under [%s] is disabled.", disabled_workspaces[i]),
				vim.log.levels.WARN,
				{ title = "LSP Formatter Warning" }
			)
			return
		end
	end

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local clients = vim.lsp.buf_get_clients(bufnr)

	if opts.filter then
		clients = opts.filter(clients)
	elseif opts.id then
		clients = vim.tbl_filter(function(client)
			return client.id == opts.id
		end, clients)
	elseif opts.name then
		clients = vim.tbl_filter(function(client)
			return client.name == opts.name
		end, clients)
	end

	clients = vim.tbl_filter(function(client)
		return client.supports_method("textDocument/formatting")
	end, clients)

	if #clients == 0 then
		vim.notify(
			"[LSP] Format request failed, no matching language servers.",
			vim.log.levels.WARN,
			{ title = "Formatting Failed" }
		)
	end

	local timeout_ms = opts.timeout_ms
	for _, client in pairs(clients) do
		--[[
		if block_list[vim.bo.filetype] == true then
			vim.notify(
				string.format(
					"[LSP][%s] Formatter for [%s] has been disabled. This file is not being processed.",
					client.name,
					vim.bo.filetype
				),
				vim.log.levels.WARN,
				{ title = "LSP Formatter Warning" }
			)
			return
		end
		--]]

		local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
		local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
		if result and result.result then
			vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
			vim.notify(
				string.format("[LSP] Format successfully with %s", client.name),
				vim.log.levels.INFO,
				{ title = "LSP Format Success" }
			)
		elseif err then
			vim.notify(
				string.format("[LSP][%s] %s", client.name, err),
				vim.log.levels.ERROR,
				{ title = "LSP Format Error" }
			)
		end
	end
end

return M
