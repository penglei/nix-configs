--- Go build configuration: dynamically switch gopls GOOS/GOARCH and build tags
--- without restarting the LSP. Also syncs build tags into neotest-golang.
---
--- Commands:
---   :GoSetGOOS {platform}   — e.g. linux, windows, darwin. No arg = picker.
---   :GoSetGOARCH {arch}     — e.g. amd64, arm64. No arg = picker.
---   :GoSetTags {tags}       — e.g. integration,e2e. No arg = scan project for tags.
---   :GoReset                — clear all overrides back to defaults.
local M = {}

--- nil = use the real platform / no tags (gopls default behavior)
local state = {
	goos = nil,
	goarch = nil,
	tags = nil,
}

local GOOS_OPTIONS = {
	"darwin", "linux", "windows", "freebsd", "openbsd", "netbsd",
	"dragonfly", "solaris", "aix", "android", "ios", "js", "plan9",
}

local GOARCH_OPTIONS = {
	"amd64", "arm64", "386", "arm", "wasm",
	"mips", "mips64", "mipsle", "mips64le",
	"ppc64", "ppc64le", "s390x", "riscv64",
}

--- Format the current state for display
local function state_desc()
	local parts = {}
	table.insert(parts, "GOOS=" .. (state.goos or "default"))
	table.insert(parts, "GOARCH=" .. (state.goarch or "default"))
	table.insert(parts, "tags=" .. (state.tags and state.tags ~= "" and state.tags or "none"))
	return table.concat(parts, ", ")
end

--- Apply current state to all running gopls clients via workspace/didChangeConfiguration.
--- No LSP restart needed — gopls re-indexes in the background.
function M.apply()
	local clients = vim.lsp.get_clients({ name = "gopls" })
	if #clients == 0 then
		vim.notify("gopls not attached — settings will apply on next start", vim.log.levels.WARN)
		return
	end
	for _, client in ipairs(clients) do
		local settings = vim.deepcopy(client.config.settings or {})
		settings.gopls = settings.gopls or {}
		settings.gopls.build = settings.gopls.build or {}
		-- env: empty table = no overrides (gopls uses real platform)
		settings.gopls.build.env = {}
		if state.goos then settings.gopls.build.env.GOOS = state.goos end
		if state.goarch then settings.gopls.build.env.GOARCH = state.goarch end
		-- buildFlags
		if state.tags and state.tags ~= "" then
			settings.gopls.build.buildFlags = { "-tags=" .. state.tags }
		else
			settings.gopls.build.buildFlags = nil
		end
		client.config.settings = settings
		client.notify("workspace/didChangeConfiguration", { settings = settings })
	end
end

--- neotest-golang: go test args (preserves default flags, appends -tags if set)
function M.get_test_args()
	local args = { "-v", "-race", "-count=1" }
	if state.tags and state.tags ~= "" then
		table.insert(args, "-tags=" .. state.tags)
	end
	return args
end

--- neotest-golang: go list args
function M.get_list_args()
	if state.tags and state.tags ~= "" then
		return { "-tags=" .. state.tags }
	end
	return {}
end

--- Scan the project for build tags from //go:build directives.
--- Returns a sorted list of unique word tokens found in build constraints.
local function scan_build_tags()
	local output = vim.fn.systemlist({
		"rg", "-o", "//go:build\\s+\\K.*", "--no-filename", "-g", "*.go",
	})
	if vim.v.shell_error ~= 0 then
		return {}
	end
	local seen = {}
	local tags = {}
	for _, line in ipairs(output) do
		for word in line:gmatch("[%w_]+") do
			if not seen[word] then
				seen[word] = true
				tags[#tags + 1] = word
			end
		end
	end
	table.sort(tags)
	return tags
end

--- Open a snacks picker to choose from `options`.
--- `on_confirm` receives the chosen string (or nil for "default").
local function pick_option(title, options, current, on_confirm)
	local items = {}
	-- "(default)" option to clear the override
	items[#items + 1] = {
		text = "(default)",
		item = nil,
	}
	for _, opt in ipairs(options) do
		items[#items + 1] = {
			text = opt .. (opt == current and "  ✓" or ""),
			item = opt,
		}
	end
	Snacks.picker.pick({
		title = title,
		items = items,
		confirm = function(picker, item)
			picker:close()
			vim.schedule(function()
				on_confirm(item and item.item)
			end)
		end,
	})
end

--- Completion function for a fixed list of options (GOOS / GOARCH).
local function complete_from_list(options)
	return function(arg_lead)
		local matches = {}
		for _, opt in ipairs(options) do
			if opt:find(arg_lead, 1, true) == 1 then
				matches[#matches + 1] = opt
			end
		end
		return matches
	end
end

--- Completion for build tags: scans the project and completes the last
--- comma-separated segment so the user can type `integration,e` → `e2e`.
local function complete_tags(arg_lead)
	local tags = scan_build_tags()
	local parts = vim.split(arg_lead, ",", { plain = true })
	local prefix = ""
	if #parts > 1 then
		prefix = table.concat(parts, ",", 1, #parts - 1) .. ","
	end
	local last = parts[#parts]
	local matches = {}
	for _, tag in ipairs(tags) do
		if tag:find(last, 1, true) == 1 then
			matches[#matches + 1] = prefix .. tag
		end
	end
	return matches
end

-- :GoSetGOOS {platform}  — no arg opens picker
vim.api.nvim_create_user_command("GoSetGOOS", function(args)
	if args.args ~= "" then
		state.goos = args.args
		M.apply()
		vim.notify("GOOS set to " .. state.goos .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
	else
		pick_option("Set GOOS", GOOS_OPTIONS, state.goos, function(chosen)
			state.goos = chosen
			M.apply()
			vim.notify("GOOS set to " .. (chosen or "default") .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
		end)
	end
end, { nargs = "?", desc = "Set gopls GOOS for cross-platform source browsing", complete = complete_from_list(GOOS_OPTIONS) })

-- :GoSetGOARCH {arch}  — no arg opens picker
vim.api.nvim_create_user_command("GoSetGOARCH", function(args)
	if args.args ~= "" then
		state.goarch = args.args
		M.apply()
		vim.notify("GOARCH set to " .. state.goarch .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
	else
		pick_option("Set GOARCH", GOARCH_OPTIONS, state.goarch, function(chosen)
			state.goarch = chosen
			M.apply()
			vim.notify("GOARCH set to " .. (chosen or "default") .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
		end)
	end
end, { nargs = "?", desc = "Set gopls GOARCH for cross-platform source browsing", complete = complete_from_list(GOARCH_OPTIONS) })

-- :GoSetTags {tags}  — comma-separated; no arg scans project and opens picker
vim.api.nvim_create_user_command("GoSetTags", function(args)
	if args.args ~= "" then
		state.tags = args.args
		M.apply()
		vim.notify("Build tags set to: " .. state.tags .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
	else
		local tags = scan_build_tags()
		if #tags == 0 then
			vim.notify("No //go:build tags found in project", vim.log.levels.WARN)
			return
		end
		pick_option("Set Build Tags", tags, state.tags, function(chosen)
			state.tags = chosen
			M.apply()
			vim.notify("Build tags set to: " .. (chosen or "none") .. " (" .. state_desc() .. ")", vim.log.levels.INFO)
		end)
	end
end, { nargs = "?", desc = "Set gopls build tags (scan project if no arg)", complete = complete_tags })

-- :GoReset — clear all overrides
vim.api.nvim_create_user_command("GoReset", function()
	state.goos = nil
	state.goarch = nil
	state.tags = nil
	M.apply()
	vim.notify("Go build config reset to defaults (" .. state_desc() .. ")", vim.log.levels.INFO)
end, { desc = "Reset GOOS/GOARCH/build tags to defaults" })

return M
