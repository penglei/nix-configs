local copilot_config = {
	panel = { enabled = false },
	suggestion = {
		auto_trigger = true,
		hide_during_completion = false,
		keymap = {
			accept = false, -- "<M-l>",
			accept_word = false,
			accept_line = false,
			next = false, -- "<M-]>",
			prev = false, --"<M-[>",
			dismiss = false, -- "<C-/>",
		},
	},
	filetypes = {
		markdown = true,
		yaml = true,
	},
}

local codecompanion_config = (function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"codecompanion",
		},
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
		end,
	})

	local icons = { aichat = require("config.ui.icons").get("aichat", true) }

	local chat_models = {
		-- free models
		"mistralai/devstral-small:free", -- default
		"qwen/qwen-2.5-coder-32b-instruct:free",
		"deepseek/deepseek-chat-v3-0324:free",
		"deepseek/deepseek-r1:free",
		"google/gemma-3-27b-it:free",
		-- paid models
		"openai/codex-mini",
		"openai/gpt-4.1-mini",
		"google/gemini-2.0-flash-001",
		"google/gemini-2.5-flash-preview-05-20",
		"anthropic/claude-3.7-sonnet",
		"anthropic/claude-sonnet-4",
	}

	local current_model = chat_models[4] -- "deepseek/deepseek-r1:free"
	local current_chat_model = current_model

	vim.notify("DEEPSEEK_API_KEY: \n" .. string.rep("*", string.len(vim.env["DEEPSEEK_API_KEY"] or "")))
	vim.notify("OPENROUTER_API_KEY: \n" .. string.rep("*", string.len(vim.env["OPENROUTER_API_KEY"] or "")))

	local strategies = {
		openrouter = {
			inline = {
				adapter = "openrouter",
			},
			chat = {
				adapter = "openrouter",
				roles = {
					llm = function(adapter) return icons.aichat.Copilot .. "CodeCompanion (" .. adapter.formatted_name .. ")" end,
					user = icons.aichat.Me .. "Me",
				},
				keymaps = {
					submit = {
						modes = { n = "<CR>" },
						description = "Submit",
						callback = function(chat)
							chat:apply_model(current_model)
							chat:submit()
						end,
					},
				},
			},
		},
		deepseek = { -- env:DEEPSEEK_API_KEY
			chat = { adapter = "deepseek" },
			inline = { adapter = "deepseek" },
		},
	}

	return {
		opts = {
			language = "Chinese",
			log_level = "DEBUG",
		},
		strategies = strategies.deepseek,

		adapters = {
			openrouter = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						url = "https://openrouter.ai/api",
						api_key = vim.fn.getenv("OPENROUTER_API_KEY") or "",
						chat_url = "/v1/chat/completions",
					},
					schema = {
						model = {
							default = current_chat_model,
						},
					},
				})
			end,
		},
		display = {
			diff = {
				enabled = true,
				close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
				layout = "vertical", -- vertical|horizontal split for default provider
				opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
				provider = "default", -- default|mini_diff
			},
			chat = {
				window = {
					layout = "vertical", -- float|vertical|horizontal|buffer
					position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
					border = "single",
					width = 0.25,
					relative = "editor",
					full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
				},
			},
		},
		extensions = {
			history = {
				enabled = true,
				opts = {
					-- Keymap to open history from chat buffer (default: gh)
					keymap = "gh",
					-- Automatically generate titles for new chats
					auto_generate_title = true,
					---On exiting and entering neovim, loads the last chat on opening chat
					continue_last_chat = false,
					---When chat is cleared with `gx` delete the chat from history
					delete_on_clearing_chat = false,
					-- Picker interface ("telescope", "snacks" or "default")
					picker = "snacks",
					---Enable detailed logging for history extension
					enable_logging = false,
					---Directory path to save the chats
					dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
					-- Save all chats by default
					auto_save = true,
					-- Keymap to save the current chat manually
					save_chat_keymap = "sc",
					-- Number of days after which chats are automatically deleted (0 to disable)
					expiration_days = 0,
				},
			},
		},
	}
end)()

require("copilot").setup(copilot_config)
require("codecompanion").setup(codecompanion_config)
