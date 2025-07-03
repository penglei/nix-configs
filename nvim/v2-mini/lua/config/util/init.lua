---@class keymap_options
local keymap_options = {}

---@return keymap_options
function keymap_options:new(buffer)
	local instance = {
		cmd = "",
		options = {
			noremap = true,
			silent = true,
			expr = false,
			nowait = false,
			callback = nil,
			desc = "",
		},
		buffer = buffer,
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function keymap_options:map_cmd(cmd_string)
	self.cmd = cmd_string
	return self
end

function keymap_options:map_cr(cmd_string)
	self:map_cmd((":%s<CR>"):format(cmd_string))
	return self
end

function keymap_options:map_args(cmd_string)
	self:map_cmd((":%s<Space>"):format(cmd_string))
	return self
end

function keymap_options:map_cu(cmd_string)
	-- <C-u> to eliminate the automatically inserted range in visual mode
	self:map_cmd((":<C-u>%s<CR>"):format(cmd_string))
	return self
end

function keymap_options:map_callback(callback)
	self.cmd = ""
	self.options.callback = callback
	return self
end

function keymap_options:silent(v)
	if v ~= nil and v == false then self.options.silent = false end
	return self
end

function keymap_options:desc(description_string)
	self.options.desc = description_string
	return self
end

function keymap_options:noremap(v)
	if v ~= nil and v == false then self.options.silent = false end
	return self
end

function keymap_options:expr(v)
	if v then self.options.expr = true end
	return self
end

function keymap_options:nowait(v)
	if v then self.options.nowait = true end
	return self
end

function keymap_options:buffer(num)
	self.buffer = num
	return self
end

---@class bind
local bind = {
	buf = nil,
}

---@return keymap_options
function bind.map_cr(cmd_string) return keymap_options:new():map_cr(cmd_string) end

---@return keymap_options
function bind.map_cmd(cmd_string) return keymap_options:new():map_cmd(cmd_string) end

---@return keymap_options
function bind.map_cu(cmd_string) return keymap_options:new():map_cu(cmd_string) end

---@return keymap_options
function bind.map_args(cmd_string) return keymap_options:new():map_args(cmd_string) end

---@return keymap_options
function bind.map_callback(callback) return keymap_options:new():map_callback(callback) end

--- @return string
function bind.escape_termcode(cmd_string) return vim.api.nvim_replace_termcodes(cmd_string, true, true, true) end

--- @return bind
function bind:new(buf)
	local instance = {
		buf = buf,
	}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function bind:load(mapping)
	for key, value in pairs(mapping) do
		local modes, keymap = key:match("([^|]*)|?(.*)")
		if type(value) == "table" then
			for _, mode in ipairs(vim.split(modes, "")) do
				local rhs = value.cmd
				local options = value.options

				local buf = self.buf
				if value.buffer and type(value.buffer) == "number" then buf = value.buffer end

				if buf and type(buf) == "number" then
					vim.api.nvim_buf_set_keymap(buf, mode, keymap, rhs, options)
				else
					--- vim.keymap.set(mode, keymap, rhs) ---
					vim.api.nvim_set_keymap(mode, keymap, rhs, options)
				end
			end
		end
	end
end

local win = {
	calsize = function(w, h)
		local screen_w = vim.opt.columns:get()
		local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()

		if w == nil then w = 0.2 end
		if h == nil then h = 0.8 end

		local window_w = w
		local window_h = h

		if w < 1 then window_w = screen_w * w end
		if h < 1 then window_h = screen_h * h end

		return {
			width = window_w,
			height = window_h,
		}
	end,
}
return {
	autocmd_filetype_close = function(filetype, opts)
		if opts == nil then opts = {} end

		local group = opts.group

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { filetype },
			group = group,
			callback = function(event)
				vim.bo[event.buf].buflisted = false
				vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true, noremap = true, nowait = true })
			end,
		})
	end,

	bind = bind,

	win = win,
}
