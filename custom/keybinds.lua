-- Custom keybinds. Loaded after hyprland/keybinds.lua.
--
-- Hyprland fires EVERY bind matching a keycombo, not just the first — so a key
-- bound here does NOT replace a base bind on the same key, it runs alongside it.
-- To take a key over, the base bind must be deleted in hyprland/keybinds.lua.
--
-- The Super+/ cheatsheet parses this file (get_keybinds.py, wired up in the
-- shell's services/HyprlandKeybinds.qml). Three things matter to it:
--   * `--##!` marks a section heading.
--   * `description = "Category: Action"` — text before the ":" becomes the
--     cheatsheet column. Reuse the base's categories (App, Window, Media,
--     Screen, Shell, Utilities, Workspace, Session) to merge into its columns.
--   * `-- # [hidden]` after a bind omits it. Omitting the description does NOT
--     hide a bind — the parser synthesizes one from the dispatcher, which is how
--     "Execute: playerctl" rows appear. Mark alias keys [hidden] so each action
--     is listed exactly once.
-- The parser is static: it cannot resolve a key built from a table lookup
-- (`keys[i]`), so bind such keys literally or mark the loop [hidden].

local exec = function(c)
	return hl.dsp.exec_cmd(c)
end
local home = os.getenv("HOME")

local locked = { locked = true }
local lockedRep = { locked = true, repeating = true }

--##! Apps
hl.bind("SUPER + Space", exec("vicinae toggle"), { description = "App: Launcher" })
hl.bind("SUPER + V", exec("clipse-gui"), { description = "App: Clipboard history" })
hl.bind(
	"SUPER + W",
	exec("__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia zen-browser"),
	{ description = "App: Browser (dGPU)" }
)
hl.bind("SUPER + SHIFT + F", exec("figma-linux"), { description = "App: Figma" })
hl.bind("SUPER + SHIFT + I", exec([[XDG_CURRENT_DESKTOP="gnome" gnome-control-center]]), {
	description = "App: GNOME settings",
})
hl.bind("SUPER + CTRL + E", exec("HYPRSHOT_EDITOR=1 quickshell -c HyprQuickFrame -n"), {
	description = "App: Screenshot editor",
})
hl.bind("ALT + Tab", exec("hypr-alttab"), { description = "App: Window switcher" })

--##! Config
hl.bind(
	"CTRL + SUPER + Slash",
	exec("kitty -e nvim " .. home .. "/.config/illogical-impulse/config.json"),
	{ description = "Config: Edit shell config" }
)
hl.bind(
	"CTRL + SUPER + ALT + Slash",
	exec("xdg-open " .. home .. "/.config/hypr/custom/keybinds.lua"),
	{ description = "Config: Edit custom keybinds" }
)

--##! Window
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill(), { description = "Window: Force close" })
-- Requires `wayscriber` on PATH; the bind is inert without it.
hl.bind("SUPER + SHIFT + D", exec("pkill -SIGUSR1 wayscriber"), { description = "Window: Toggle screen annotation" })

--##! Layout
--# Scrolling layout dispatchers. `general:layout = "scrolling"` is set in
--# custom/general.lua, so these are the primary window-arrangement keys.
hl.bind("SUPER + CTRL + Left", hl.dsp.layout("colresize -0.1"), { description = "Layout: Shrink column" })
hl.bind("SUPER + CTRL + Right", hl.dsp.layout("colresize +0.1"), { description = "Layout: Grow column" })
hl.bind("SUPER + CTRL + C", hl.dsp.layout("alignwindow c"), { description = "Layout: Center window" })
hl.bind("SUPER + CTRL + H", hl.dsp.layout("admitwindow"), { description = "Layout: Admit window into column" })
hl.bind("SUPER + CTRL + X", hl.dsp.layout("expelwindow"), { description = "Layout: Expel window from column" })
hl.bind("SUPER + SHIFT + Comma", hl.dsp.layout("move -col"), { description = "Layout: Focus column left" })
hl.bind("SUPER + SHIFT + Period", hl.dsp.layout("move +col"), { description = "Layout: Focus column right" })
hl.bind("SUPER + CTRL + Comma", hl.dsp.layout("swapcol l"), { description = "Layout: Swap column left" })
hl.bind("SUPER + CTRL + Period", hl.dsp.layout("swapcol r"), { description = "Layout: Swap column right" })

--##! Screen
-- Zoom in/out live on SUPER + Minus/Equal in hyprland/keybinds.lua.
hl.bind("SUPER + mouse:274", exec("hyprctl keyword cursor:zoom_factor 1"), {
	mouse = true,
	description = "Screen: Reset zoom",
})
hl.bind("SUPER + Z", exec("woomer"), {
	description = "Screen: Zoom",
})

--##! Media
--# Aliases of the described binds in hyprland/keybinds.lua, marked [hidden] so
--# the cheatsheet lists each action once.
hl.bind("CTRL + mouse:275", exec("playerctl previous"), locked) -- # [hidden]
hl.bind(
	"CTRL + mouse:276",
	exec([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]),
	locked
) -- # [hidden]
hl.bind("CTRL + XF86AudioRaiseVolume", exec("playerctl next"), lockedRep) -- # [hidden]
hl.bind("CTRL + XF86AudioLowerVolume", exec("playerctl previous"), lockedRep) -- # [hidden]
hl.bind("CTRL + XF86AudioMute", exec("playerctl play-pause"), lockedRep) -- # [hidden]

--# Seeking has no base equivalent, so it is described here.
hl.bind("ALT + XF86AudioRaiseVolume", exec("playerctl position 2+"), {
	locked = true,
	repeating = true,
	description = "Media: Seek forward 2s",
})
hl.bind("ALT + XF86AudioLowerVolume", exec("playerctl position 2-"), {
	locked = true,
	repeating = true,
	description = "Media: Seek back 2s",
})
