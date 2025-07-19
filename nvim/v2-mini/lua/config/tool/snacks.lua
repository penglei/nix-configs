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
require("snacks").setup({
	notifier = { enabled = true },
	input = { enabled = true },
	image = {
		enabled = true,
		doc = { -- it will render image in markdown
			inline = false,
			max_width = 100,
			max_height = 60,
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
						function(data) return ("%s[%s]"):format(data.src, data.params.page) end,
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
		win = {
			input = {
				keys = {
					["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
					["<Tab>"] = { "list_down", mode = { "i", "n" } },
				},
			},
		},
		layout = {
			cycle = true,
			--- Use the default layout or vertical if the window is too narrow
			preset = function() return vim.o.columns >= 120 and "default" or "ivy_split" end,
		},
	},
})
