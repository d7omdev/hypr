-- This file sources other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`

-- Internal stuff --
require("hyprland.lib")
require("hyprland.services")

-- Environment variables --
require("hyprland.env")
if is_file_exists(HOME .. "/.config/hypr/custom/env.lua") then
	require("custom.env")
end

-- Default configurations --
require("hyprland.execs")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
require("hyprland.keybinds")
require("hyprland.plugins")

-- Custom configurations --
if is_file_exists(HOME .. "/.config/hypr/custom/execs.lua") then
	require("lua.custom.execs")
end
if is_file_exists(HOME .. "/.config/hypr/custom/general.lua") then
	require("lua.custom.general")
end
if is_file_exists(HOME .. "/.config/hypr/custom/rules.lua") then
	require("lua.custom.rules")
end
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
	require("lua.custom.keybinds")
end

-- nwg-displays support --
if is_file_exists(HOME .. "/.config/hypr/workspaces.lua") then
	require("workspaces")
end
if is_file_exists(HOME .. "/.config/hypr/monitors.lua") then
	require("monitors")
end

-- Shell overrides --
require("hyprland.shellOverrides.main")
