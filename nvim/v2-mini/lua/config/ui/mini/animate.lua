local animate = require("mini.animate")
animate.setup({
	resize = {
		enable = false,
	},
	scroll = {
		timing = animate.gen_timing.cubic({ duration = 120, unit = "total" }),
	},
	cursor = {
		timing = animate.gen_timing.cubic({ duration = 100, unit = "total" }),
	},
})
