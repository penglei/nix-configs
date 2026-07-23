--- https://github.com/folke/snacks.nvim?tab=readme-ov-file#-usage
local function parse_path_and_params(src)
	local param_start = string.find(src, "#", 1, true)

	if not param_start then return src, {} end

	local path = string.sub(src, 1, param_start - 1)

	local param_str = string.sub(src, param_start + 1)
	local params = {}

	for pair in string.gmatch(param_str, "[^&]+") do
		local pos = string.find(pair, "=", 1, true)
		if pos then
			local key = string.sub(pair, 1, pos - 1)
			local value = string.sub(pair, pos + 1)
			params[key] = value
		end
	end

	return path, params
end

--- Build a custom preview-toggle action that shows the preview at `width`
--- (a fraction of the picker width). Behaviour:
---   * hidden  -> show at `width`
---   * shown at `width`   -> hide
---   * shown at other width -> switch to `width`
local function preview_toggle_at(width)
	return function(picker)
		local layout = picker.layout
		local function find_preview(box)
			if box.win == "preview" then return box end
			for _, child in ipairs(box) do
				local found = find_preview(child)
				if found then return found end
			end
		end
		local box = find_preview(layout.opts.layout)
		local hidden = layout:is_hidden("preview")
		if not hidden and box and box.width == width then
			picker:toggle("preview", { enable = false })
		else
			if box then box.width = width end
			if hidden then
				picker:toggle("preview", { enable = true })
			else
				layout:update()
			end
		end
	end
end

--- Grep-style pickers: the result list already shows the matched line,
--- so preview is hidden by default. When toggled on, Tab uses 80% width
--- (the grep summary is too brief; you want to focus on the file content).
--- Shift-Tab uses 50% for a quick glance that keeps more of the list visible.
local grep_preview = {
	layout = { hidden = { "preview" } },
	win = {
		input = {
			keys = {
				["<Tab>"] = { "toggle_preview_wide", mode = { "i", "n" } },
				["<S-Tab>"] = { "toggle_preview_half", mode = { "i", "n" } },
			},
		},
	},
}

require("snacks").setup({
	notifier = { enabled = true },
	input = { enabled = true },
	toggle = { enabled = true },
	image = {
		enabled = false,
		doc = { -- it will render image in markdown
			inline = false,
			max_width = 180,
			max_height = 120,
		},
		transforms = {
			markdown_inline = function() vim.notify("markdown_inline") end,
		},
		---@diagnostic disable-next-line: missing-fields
		convert = {
			magick = {
				pdf = function()
					return {
						"-density",
						192,
						function(data) return ("%s[%s]"):format(data.src, data.params.page or 0) end,
						"-background",
						"white",
						"-alpha",
						"remove",
						"-trim",
					}
				end,
			},
		},
		resolve = function(file, src_text)
			local src, params = parse_path_and_params(src_text)

			if not src:find("^%w%w+://") then
				local cwd = vim.uv.cwd() or "."
				local checks = { [src] = true }
				for _, root in ipairs({ cwd, vim.fs.dirname(file) }) do
					checks[root .. "/" .. src] = true
					for _, dir in ipairs(Snacks.image.config.img_dirs) do
						dir = root .. "/" .. dir
						if vim.fn.isdirectory(dir) == 1 then checks[dir .. "/" .. src] = true end
					end
				end
				for f in pairs(checks) do
					if vim.fn.filereadable(f) == 1 then
						src = vim.uv.fs_realpath(f) or f
						break
					end
				end
				src = vim.fs.normalize(src)
			end

			local page = tonumber(params.page) or 0

			if page < 0 then
				page = 0
			elseif page > 0 then
				page = page - 1
			end
			params.page = page
			params.key = src

			if params.page then params.key = src .. "#" .. tostring(params.page) end
			-- vim.notify("params:" .. vim.inspect(params))
			return {
				src = src,
				params = params,
			}
		end,
	},
	styles = {
		---@diagnostic disable-next-line: missing-fields
		input = {
			row = require("config.util").win.calsize(1, 0.5).height,
			b = {
				completion = true,
			},
			keys = { i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true } },
		},
	},
	picker = {
		actions = {
			-- Tab / Shift-Tab use these instead of the built-in toggle_preview
			-- so we can control the preview window width.
			toggle_preview_half = preview_toggle_at(0.5),
			toggle_preview_wide = preview_toggle_at(0.8),
		},
		win = {
			input = {
				keys = {
					-- emacs-style cursor movement in the input box
					["<C-a>"] = { "<Home>", mode = { "i" }, expr = true, desc = "cursor to line start" },
					["<C-e>"] = { "<End>", mode = { "i" }, expr = true, desc = "cursor to line end" },
					["<C-b>"] = { "<Left>", mode = { "i" }, expr = true, desc = "cursor back" },
					["<C-f>"] = { "<Right>", mode = { "i" }, expr = true, desc = "cursor forward" },
					["<M-b>"] = { "<C-Left>", mode = { "i" }, expr = true, desc = "cursor word back" },
					["<M-f>"] = { "<C-Right>", mode = { "i" }, expr = true, desc = "cursor word forward" },
					-- C-u: emacs-style in insert mode (delete to line start),
					-- but list_scroll_up in normal mode (snacks default).
					-- Emacs keys are insert-only; normal/visual keep vim/snacks behavior.
					["<C-u>"] = {
						function(self)
							if vim.fn.mode() == "i" then
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<C-u>", true, false, true),
									"n",
									false
								)
							else
								self:action("list_scroll_up")()
							end
						end,
						mode = { "i", "n" },
						desc = "C-u: delete to line start (i) / scroll list up (n)",
					},
					-- Tab: preview at 50% (default width). Shift-Tab: preview at 80%.
					["<S-Tab>"] = { "toggle_preview_wide", mode = { "i", "n" } },
					["<Tab>"] = { "toggle_preview_half", mode = { "i", "n" } },
				},
			},
		},
		layout = {
			cycle = true,
			--- Use the default layout or vertical if the window is too narrow
			preset = function() return vim.o.columns >= 120 and "default" or "ivy_split" end,
		},
		sources = {
			-- smart = <leader>f: hide preview by default so the filename list gets
			-- the full width. Press <Tab> to toggle the preview on.
			smart = { layout = { hidden = { "preview" } } },
			-- grep = <leader>/, grep_word = <leader>w: see `grep_preview` above.
			-- <leader>/ uses Snacks.picker.resume({ source = "grep" }) so the
			-- search string, cursor position, and scroll are all restored.
			grep = grep_preview,
			grep_word = grep_preview,
			-- recent = <leader>r: only show files under the current working
			-- directory, so current-project files aren't drowned out by
			-- oldfiles from other projects.
			recent = { filter = { cwd = true } },
			-- notifications: Enter opens the full message in a buffer so the
			-- user can read and yank the error text (the picker preview is
			-- read-only and doesn't allow copying).
			notifications = {
				confirm = function(picker, item)
					local notif = item.item
					picker:close()
					vim.schedule(function()
						local lines = {
							"# " .. (notif.title or "Notification"),
							"",
							"**Level:** " .. notif.level,
							"**Time:** " .. os.date("%Y-%m-%d %H:%M:%S", notif.added / 1e9),
							"",
							"---",
							"",
						}
						vim.list_extend(lines, notif.msg and vim.split(notif.msg, "\n") or { "(empty)" })
						vim.cmd("split")
						local buf = vim.api.nvim_create_buf(false, true)
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
						-- pcall: name may already exist if the same notification
						-- is opened twice — the buffer works fine without a name.
						pcall(vim.api.nvim_buf_set_name, buf, "Notification:" .. (notif.title or tostring(notif.id)))
						vim.bo[buf].filetype = "markdown"
						vim.bo[buf].modifiable = false
						vim.bo[buf].buftype = "nofile"
						vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = buf, silent = true, nowait = true })
						vim.api.nvim_win_set_buf(0, buf)
					end)
				end,
			},
		},
	},
})
