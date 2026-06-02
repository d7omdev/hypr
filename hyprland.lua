-- Hyprland 0.55+ Lua entry point.
-- Activated via: mv hyprland.lua.draft hyprland.lua && mv hyprland.conf hyprland.conf.bak
-- Test in nested session first: Hyprland -c $HOME/.config/hypr/hyprland.lua.draft
--
-- Load order mirrors the old hyprland.conf source order:
--   1. defaults (lua/)
--   2. custom overrides (lua/custom/)
--   3. plugin settings
--   4. HyprMod-managed GUI overrides — LAST so the tool wins, matching
--      `source = hyprland-gui.conf` at the bottom of the old conf.

-- Make lua/ requireable.
package.path = os.getenv("HOME") .. "/.config/hypr/lua/?.lua;" .. package.path

-- Defaults
require("env")
require("execs")
require("general")
require("animations")
require("rules")
require("colors")
require("keybinds")

-- Custom overrides
require("custom.env")
require("custom.execs")
require("custom.general")
require("custom.rules")
require("custom.keybinds")

-- Plugin settings (no-op until plugin loaded via hyprpm)
require("plugins")

-- HyprMod GUI overrides — load LAST
require("gui")
