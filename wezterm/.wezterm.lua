local wezterm = require "wezterm"

local config = wezterm.config_builder()

config.color_scheme = "GruvboxDark"
config.font = wezterm.font "Mononoki"
-- config.window_decorations = "NONE"
config.font_size = 18.0

config.keys = {}

for i = 1, 9 do
  -- ALT + number to move to that position
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config
