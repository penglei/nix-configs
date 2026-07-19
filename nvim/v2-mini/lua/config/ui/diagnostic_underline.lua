-- nvim 0.12.4: vim.diagnostic.handlers.underline.show calls
--   nvim_buf_get_lines(diagnostic.bufnr, diagnostic.lnum, diagnostic.lnum + 1, true)
-- without clamping diagnostic.lnum. If a stale diagnostic (lnum >= line_count)
-- is shown — e.g., LSP sent publishDiagnostics for an unloaded buffer created by
-- snacks picker's bufadd() (vim/lsp/diagnostic.lua:244-253), with lnum from
-- unsaved/old content; then :buffer loads the file from disk with fewer lines —
-- the strict-indexing call throws "Index out of bounds", breaking the picker's
-- file jump. The signs handler already guards with `if lnum <= line_count` and
-- the location-extmark setup in vim.diagnostic.set clamps with math.min(lnum,
-- last_row); the underline handler does neither. Filter out-of-range
-- diagnostics before delegating, deferring via BufReadPost to mirror the
-- original show_once_loaded -> once_buf_loaded deferral (so we filter against
-- the actual file content, not the empty unloaded buffer).
--
-- Loaded from config.ui.widgets, alongside lsp_lines / tiny-inline-diagnostic
-- setup. Verified to fix the reported `<space>f` picker crash on nvim 0.12.4;
-- the bug is still present on neovim master (_handlers.lua).
do
	local api = vim.api
	local orig_show = vim.diagnostic.handlers.underline.show
	local orig_hide = vim.diagnostic.handlers.underline.hide
	local DEFER_KEY = "underline_filter_autocmd"

	local function show_filtered(namespace, bufnr, diagnostics, opts)
		local filtered = {}
		for _, d in ipairs(diagnostics) do
			if api.nvim_buf_is_valid(d.bufnr) then
				local line_count = api.nvim_buf_line_count(d.bufnr)
				if d.lnum >= 0 and d.lnum < line_count then
					filtered[#filtered + 1] = d
				end
			end
		end
		return orig_show(namespace, bufnr, filtered, opts)
	end

	vim.diagnostic.handlers.underline.show = function(namespace, bufnr, diagnostics, opts)
		bufnr = vim._resolve_bufnr(bufnr)
		if api.nvim_buf_is_loaded(bufnr) then
			return show_filtered(namespace, bufnr, diagnostics, opts)
		end
		local ns = vim.diagnostic.get_namespace(namespace)
		if ns.user_data[DEFER_KEY] then
			pcall(api.nvim_del_autocmd, ns.user_data[DEFER_KEY])
		end
		ns.user_data[DEFER_KEY] = api.nvim_create_autocmd("BufReadPost", {
			buf = bufnr,
			once = true,
			callback = function()
				ns.user_data[DEFER_KEY] = nil
				show_filtered(namespace, bufnr, diagnostics, opts)
			end,
		})
	end

	vim.diagnostic.handlers.underline.hide = function(namespace, bufnr)
		local ns = vim.diagnostic.get_namespace(namespace)
		if ns.user_data[DEFER_KEY] then
			pcall(api.nvim_del_autocmd, ns.user_data[DEFER_KEY])
			ns.user_data[DEFER_KEY] = nil
		end
		return orig_hide(namespace, bufnr)
	end
end
