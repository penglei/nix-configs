--- AI interaction modes: completion -> code editing(chat) -> agent operating whole project(chat with longer context, and/or RAG)
--- completions:
--- 	https://github.com/zbirenbaum/copilot.lua
--- 	https://github.com/supermaven-inc/supermaven-nvim
--- 	https://github.com/milanglacier/minuet-ai.nvim
---
--- editing:
--- 	codecompanion.nvim
---

--- RAG:
--- 	https://github.com/Davidyz/VectorCode

---@diagnostic disable-next-line: unused-local
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
	debounce = 150,
	copilot_model = "gpt-4o-copilot", -- "claude-3.7-sonnet",
	filetypes = {
		markdown = false,
		yaml = true,
	},
	logger = {
		-- print_log_level = vim.log.levels.TRACE,
	},
}

---@diagnostic disable-next-line: unused-local
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

	-- vim.notify("DEEPSEEK_API_KEY: \n" .. string.rep("*", string.len(vim.env["DEEPSEEK_API_KEY"] or "")))
	-- vim.notify("OPENROUTER_API_KEY: \n" .. string.rep("*", string.len(vim.env["OPENROUTER_API_KEY"] or "")))

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
			-- log_level = "DEBUG",
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
			deepseek_siliconflow = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						url = "https://api.siliconflow.com/v1",
						api_key = vim.fn.getenv("SILICONFLOW_API_KEY") or "",
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

------------------------ chat -------------------------
require("codecompanion").setup(codecompanion_config)
--------------------- suggestion ----------------------
---@diagnostic disable-next-line: unused-function
local minuet_suggester = function()
	local minuet_config = {
		virtualtext = {
			auto_trigger_ft = { "go" },
			keymap = {
				-- accept whole completion
				accept = false,
				-- accept one line
				accept_line = false,
				-- accept n lines (prompts for number)
				-- e.g. "A-z 2 CR" will accept 2 lines
				accept_n_lines = false, -- "<A-z>",
				-- Cycle to prev completion item, or manually invoke completion
				prev = false, -- "<A-[>",
				-- Cycle to next completion item, or manually invoke completion
				next = false, -- "<A-]>",
				dismiss = false, -- "<A-e>",
			},
		},
		-- notify = "debug",
		request_timeout = 20,
		debounce = 600,

		-- provider = "openai_compatible",
		provider = "openai_fim_compatible",
		-- provider = "claude",

		-- n_completions = 1,
		provider_options = {
			openai_fim_compatible = {
				-- For Windows users, TERM may not be present in environment variables.
				-- Consider using APPDATA instead.
				api_key = "TERM",
				name = "Llama.cpp",
				end_point = "http://localhost:8080/v1/completions",
				-- The model is set by the llama-cpp server and cannot be altered
				-- post-launch.
				model = "PLACEHOLDER",
				optional = {
					max_tokens = 56,
					top_p = 0.9,
				},
				-- Llama.cpp does not support the `suffix` option in FIM completion.
				-- Therefore, we must disable it and manually populate the special
				-- tokens required for FIM completion.
				template = {
					prompt = function(context_before_cursor, context_after_cursor, _)
						return table.concat({
							"<|fim_prefix|>",
							context_before_cursor,
							"<|fim_suffix|>",
							context_after_cursor,
							"<|fim_middle|>",
						}, "")
					end,
					suffix = false,
				},
			},
			openai_compatible = {
				-- end_point = "https://api.deepseek.com/chat/completions",
				-- model = "deepseek-chat",
				-- api_key = "DEEPSEEK_API_KEY",
				-- stream = false,
				-- name = "deepseek",
				-- optional = {
				-- 	max_tokens = 256,
				-- 	top_p = 0.9,
				-- },

				end_point = "https://api.laozhang.ai/v1/chat/completions",
				api_key = "LAOZHANG_API_KEY",
				stream = false,
				-- model = "claude-3-7-sonnet-20250219",
				model = "claude-sonnet-4-20250514",
			},
			claude = {
				model = "claude-3-7-sonnet-20250219",

				-- end_point = "https://api.burn.hair/v1/messages",
				-- api_key = "BURN_HAIR_API_KEY",

				-- stream = false,
				-- end_point = "https://api.laozhang.ai/v1",
				-- api_key = "LAOZHANG_API_KEY",
			},
		},
	}

	require("minuet").setup(minuet_config)
	local s = require("minuet.virtualtext").action
	return {
		enabled = true,
		is_visible = s.is_visible,
		accept = s.accept, -- accept whole completion, try accept_n_lines?
		next = s.next,
		prev = s.prev,
		dismiss = s.dismiss,
	}
end

---@diagnostic disable-next-line: unused-function
local copilot_suggester = function()
	require("copilot").setup(copilot_config)
	local s = require("copilot.suggestion")
	return {
		enabled = true,
		is_visible = s.is_visible,
		accept = s.accept,
		next = s.next,
		prev = s.prev,
		dismiss = s.dismiss,
	}
end

---@diagnostic disable-next-line: unused-function
local setup_supermaven_as_cmp_provider = function()
	local supermaven_config = {
		-- keymaps = {},
		ignore_filetypes = { markdown = true },
		color = {
			suggestion_color = "#ffffff",
			cterm = 244,
		},
		log_level = "info", -- set to "off" to disable logging completely

		-- true to disable inline completion for use with cmp
		disable_inline_completion = true,

		-- true to disable built in keymaps for more manual control
		disable_keymaps = true,

		-- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
		condition = function() return false end,
	}
	require("supermaven-nvim").setup(supermaven_config)
end

-- there is no way to integrate supermaven as virtualtext and let it works well with super-tab,
-- so we use it as cmp provider instead (disable_inline_completion).
setup_supermaven_as_cmp_provider()

return {
	virtext_sugg = minuet_suggester(), --copilot_suggester(), --
}
