local global = {}
local os_name = vim.loop.os_uname().sysname

function global:load_variables()
	self.is_mac = os_name == "Darwin"
	self.is_linux = os_name == "Linux"
	self.is_windows = os_name == "Windows_NT"
	self.vim_path = vim.fn.stdpath("config")
	self.home = os.getenv("HOME")
	self.data_dir = string.format("%s/site/", vim.fn.stdpath("data"))
end

global:load_variables()

return global
