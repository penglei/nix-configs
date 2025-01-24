require("git"):setup()
require("full-border"):setup()

THEME.git = THEME.git or {}
THEME.git.modified = ui.Style():fg("blue")
THEME.git.modified_sign = "M"

THEME.git.added = ui.Style():fg("green")
THEME.git.added_sign = "A"

THEME.git.deleted = ui.Style():fg("red")
THEME.git.deleted_sign = "D"
