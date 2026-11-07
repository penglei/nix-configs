---@diagnostic disable-next-line: missing-fields
require("flash").setup({
	modes = {
		char = {
			jump_labels = true,
			-- 这些键不会作为 flash 跳转标签，便于 `f<char>` 跳转后立即按它们操作：
			--   移动:     w b e h j k l
			--   进入插入: i a
			--   操作符:   r d c y x p u ~    (y=yank x=del p=put u=undo/case ~=toggle case)
			--   位置:     o (visual 下交换选区两端 / normal 下另起新行)
			--   大写:     Y P U              (区分大小写；`~` 无大小写)
			-- 注: `~` 不在 flash 默认 label 池中, 列出仅为表达意图
			label = { exclude = "wbehjkliardcyxpou~YPU" },
		},
	},
})
