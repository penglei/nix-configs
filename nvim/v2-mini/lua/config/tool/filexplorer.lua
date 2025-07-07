local WIDTH_RATIO = 0.2
local HEIGHT_RATIO = 0.8
local OFFSET = 3

local uiicons = require("config.ui.icons")
local icons = {
	diagnostics = uiicons.get("diagnostics"),
	documents = uiicons.get("documents"),
	git = uiicons.get("git"),
	ui = uiicons.get("ui"),
}

vim.cmd([[
    :hi      NvimTreeExecFile    guifg=#ffa0a0
    :hi      NvimTreeSpecialFile guifg=#28cc9e gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
  ]])

local function nvim_tree_config_on_attach(bufnr)
	-- require("nvim-tree.api").config.mappings.default_on_attach(bufnr)
	local api = require("nvim-tree.api")
	local function opts(desc) return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end

	-- default mappings
	-- api.config.mappings.default_on_attach(bufnr)

	--custom mappings
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "q", api.tree.close, opts("Close"))
	vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
	vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
	vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
	vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
	vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
	vim.keymap.set("n", "r", api.fs.rename, opts("Rename file"))
	vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename filename basename (without ext)"))
	vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
	vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))

	vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Fileame"))
	vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
	vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))

	vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
	vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
	vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
	vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
	vim.keymap.set("n", "<leader>e", "<C-w><C-p>", opts("Back to window")) -- maybe we should do more carefully by record last window by `winnr("#")`
	vim.keymap.set("n", "<TAB>", "<C-w><C-p>", opts("Back to window")) -- maybe we should do more carefully by record last window by `winnr("#")`
	vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))

	local preview = require("nvim-tree-preview")
	vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
end

local nvim_tree_config = {
	auto_reload_on_write = true,
	create_in_closed_folder = false,
	disable_netrw = false,
	hijack_cursor = true,
	hijack_netrw = true,
	hijack_unnamed_buffer_when_opening = true,
	open_on_tab = false,
	respect_buf_cwd = false,
	sort_by = "name",
	sync_root_with_cwd = false,
	on_attach = nvim_tree_config_on_attach,

	view = {
		adaptive_size = false,
		centralize_selection = true,
		-- width = 40,
		width = function() return math.floor(vim.opt.columns:get() * WIDTH_RATIO) end,
		side = "left",
		preserve_window_proportions = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
		float = {
			enable = false,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = screen_w * WIDTH_RATIO
				local window_h = screen_h * HEIGHT_RATIO
				local window_w_int = math.floor(window_w)
				local window_h_int = math.floor(window_h)

				-- adjust for the offset
				local col_right_aligned = screen_w - window_w_int - OFFSET
				local row_offset = OFFSET - 3

				return {
					relative = "editor",
					border = "rounded",
					-- width = 40,
					-- height = 50,
					-- row = 1,
					-- col = 1,
					row = row_offset,
					col = col_right_aligned,
					width = window_w_int,
					height = window_h_int,
				}
			end,
		},
	},
	renderer = {
		add_trailing = false,
		group_empty = true,
		highlight_git = false,
		full_name = false,
		highlight_opened_files = "none",
		special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
		symlink_destination = true,
		indent_markers = {
			enable = true,
			icons = {
				corner = "└ ",
				edge = "│ ",
				item = "├ ",
				none = "  ",
			},
		},
		root_folder_label = ":.:s?.*?/..?",
		icons = {
			webdev_colors = true,
			git_placement = "after",
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},
			padding = " ",
			symlink_arrow = " 󰁔 ",
			glyphs = {
				default = icons.documents.Default, --
				symlink = icons.documents.Symlink, --
				bookmark = icons.ui.Bookmark,
				git = {
					unstaged = icons.git.Mod_alt,
					staged = icons.git.Add, --󰄬
					unmerged = icons.git.Unmerged,
					renamed = icons.git.Rename, --󰁔
					untracked = icons.git.Untracked, -- "󰞋"
					deleted = icons.git.Remove, --
					ignored = icons.git.Ignore, --◌
				},
				folder = {
					arrow_open = icons.ui.ArrowOpen,
					arrow_closed = icons.ui.ArrowClosed,
					-- arrow_open = "",
					-- arrow_closed = "",
					default = icons.ui.Folder,
					open = icons.ui.FolderOpen,
					empty = icons.ui.EmptyFolder,
					empty_open = icons.ui.EmptyFolderOpen,
					symlink = icons.ui.SymlinkFolder,
					symlink_open = icons.ui.FolderOpen,
				},
			},
		},
	},
	hijack_directories = {
		enable = true,
		auto_open = true,
	},
	update_focused_file = {
		enable = true,
		-- Update **the explorer root directory of the tree** if the file is not under current root directory.
		update_root = true,
		ignore_list = {},
	},
	filters = {
		dotfiles = false,
		custom = { ".DS_Store" },
		exclude = {},
	},
	actions = {
		use_system_clipboard = true,
		change_dir = {
			enable = false, -- whether change editor cwd while open file
			global = true, -- only for local buffer or golobal
			restrict_above_cwd = true,
		},
		open_file = {
			quit_on_open = false,
			resize_window = false,
			window_picker = {
				enable = true,
				chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
				exclude = {
					buftype = {
						"help",
						"nofile",
						"prompt",
						"quickfix",
						"terminal",
					},
					filetype = {
						"dap-repl",
						"diff",
						"fugitive",
						"fugitiveblame",
						"git",
						"notify",
						"NvimTree",
						"Outline",
						"qf",
						"TelescopePrompt",
						"toggleterm",
						"undotree",
						"lspsagaoutline",
					},
				},
			},
		},
		remove_file = {
			close_window = true,
		},
	},
	diagnostics = {
		enable = false,
		show_on_dirs = false,
		debounce_delay = 50,
		icons = {
			hint = icons.diagnostics.Hint_alt,
			info = icons.diagnostics.Information_alt,
			warning = icons.diagnostics.Warning_alt,
			error = icons.diagnostics.Error_alt,
		},
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 50,
	},
	git = {
		enable = true,
		ignore = true,
		show_on_dirs = true,
		timeout = 400,
	},
	trash = {
		cmd = "gio trash",
		require_confirm = true,
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = true,
	},
	log = {
		enable = false,
		truncate = false,
		types = {
			all = false,
			config = false,
			copy_paste = false,
			dev = false,
			diagnostics = false,
			git = false,
			profile = false,
			watcher = false,
		},
	},
}

local nvim_tree_preview_config = {
	max_width = math.floor(vim.opt.columns:get() * 0.9),
	max_height = math.floor((vim.opt.lines:get() - vim.opt.cmdheight:get()) * 0.9),
	image_preview = {
		enable = false,
	},
}

-- require("image").setup()
require("nvim-tree").setup(nvim_tree_config)
require("nvim-tree-preview").setup(nvim_tree_preview_config)
require("mini.files").setup({
	window = {
		preview = true,
	},
})
