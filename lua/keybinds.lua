-- Keybindings. Maps from hyprland/keybinds.conf.
-- API:
--   hl.bind("MOD + KEY", dispatcher, opts?)
--   dispatchers (selected): hl.dsp.exec_cmd(cmd), hl.dsp.window.close(),
--     hl.dsp.window.float({action="toggle"}), hl.dsp.window.drag(), hl.dsp.window.resize(),
--     hl.dsp.window.move({direction=}|{workspace=}), hl.dsp.focus({direction=}|{workspace=}),
--     hl.dsp.workspace.toggle_special(name), hl.dsp.layout(arg)
--   opts: { mouse=true } (bindm), { locked=true } (bindl), { repeating=true } (binde)
--
-- NOTE: a number of legacy flags don't have confirmed Lua equivalents yet:
--   bindd  (description for cheatsheet)
--   bindp  (pressed)
--   bindle (locked + repeating combo) — use { locked=true, repeating=true }
--   bindln (locked, no-repeat)        — use { locked=true } (default no-repeat)
--   bindld (locked + description)
--   submap dispatching
--   layoutmsg, splitratio dispatchers
--   raw `code:NN` keys
-- All flagged with TODO inline.

local home = os.getenv("HOME")
local SUPER = "SUPER"
local ipc = "qs -c noctalia-shell ipc call"

local function exec(cmd)
	return hl.dsp.exec_cmd(cmd)
end

--- Execute a quickshell IPC command.
---
--- Example:
---   ipccmd({ "wallpaper", "random", "HDMI-A-1" })
--- @param args IPCArgs
--- @return HL.Dispatcher
local function ipccmd(args)
	return exec(ipc .. " " .. table.concat(args, " "))
end

------------- SHELL -------------
hl.bind(SUPER .. " + Super_L", ipccmd({ "launcher", "toggle" }))
hl.bind(SUPER .. " + Super_R", ipccmd({ "launcher", "toggle" }))
-- hl.bind(SUPER .. " + Tab", ipccmd({ "launcher", "windows" }))
hl.bind(SUPER .. " + P", ipccmd({ "plugin:projects", "toggle" }))
hl.bind(SUPER .. " + Comma", ipccmd({ "plugin", "togglePanel", "notes-scratchpad" }))
hl.bind(SUPER .. " + Period", ipccmd({ "launcher", "emoji" }))
hl.bind(SUPER .. " + R", ipccmd({ "launcher", "command" }))

hl.bind(SUPER .. " + A", ipccmd({ "plugin:claude-code-panel", "open" }))
hl.bind(SUPER .. " + ALT + A", ipccmd({ "controlCenter", "toggle" }))
hl.bind(SUPER .. " + B", ipccmd({ "controlCenter", "toggle" }))
hl.bind(SUPER .. " + O", ipccmd({ "controlCenter", "toggle" }))
hl.bind(SUPER .. " + N", ipccmd({ "dock", "toggle" }))
hl.bind(SUPER .. " + Slash", ipccmd({ "plugin:keybind-cheatsheet", "toggle" }))
hl.bind(SUPER .. " + K", ipccmd({ "calendar", "toggle" }))
hl.bind(SUPER .. " + M", ipccmd({ "media", "toggle" }))
hl.bind(SUPER .. " + SHIFT + G", ipccmd({ "desktopWidgets", "toggle" }))
hl.bind("CTRL + ALT + Delete", ipccmd({ "sessionMenu", "toggle" }))
hl.bind(SUPER .. " + Escape", ipccmd({ "systemMonitor", "toggle" }))
hl.bind(SUPER .. " + J", ipccmd({ "bar", "toggle" }))

------------- HARDWARE KEYS -------------
local locked = { locked = true }
local lockedRep = { locked = true, repeating = true }

hl.bind("XF86MonBrightnessUp", ipccmd({ "brightness", "increase" }), lockedRep)
hl.bind("XF86MonBrightnessDown", ipccmd({ "brightness", "decrease" }), lockedRep)
hl.bind("XF86AudioRaiseVolume", ipccmd({ "volume", "increase" }), lockedRep)
hl.bind("XF86AudioLowerVolume", ipccmd({ "volume", "decrease" }), lockedRep)
hl.bind("XF86AudioMute", ipccmd({ "volume", "muteOutput" }), locked)
hl.bind(SUPER .. " + SHIFT + M", ipccmd({ "volume", "muteOutput" }), locked)
hl.bind("ALT + XF86AudioMute", ipccmd({ "volume", "muteInput" }), locked)
hl.bind("XF86AudioMicMute", ipccmd({ "volume", "muteInput" }), locked)
hl.bind(SUPER .. " + ALT + M", ipccmd({ "volume", "muteInput" }), locked)

hl.bind("CTRL + " .. SUPER .. " + T", ipccmd({ "wallpaper", "toggle" }))
hl.bind("CTRL + " .. SUPER .. " + ALT + T", ipccmd({ "wallpaper", "random" }))
hl.bind("CTRL + " .. SUPER .. " + R", exec("killall qs quickshell; qs -c noctalia-shell &"))

------------- UTILITIES (screenshot/OCR/picker) -------------
hl.bind(SUPER .. " + SHIFT + S", exec("hyprshot --freeze --clipboard-only --mode region --silent"))
hl.bind(SUPER .. " + SHIFT + A", exec(home .. "/.config/hypr/hyprland/scripts/snip_to_search.sh"))

local ocrCmd = [[grim -g "$(slurp $SLURP_ARGS)" "/tmp/ocr_image.png" && ]]
	.. [[tesseract "/tmp/ocr_image.png" stdout $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\n' '+' | sed 's/\+$/\n/') | wl-copy && ]]
	.. [[rm "/tmp/ocr_image.png"]]
hl.bind(SUPER .. " + SHIFT + X", exec(ocrCmd))
hl.bind(SUPER .. " + SHIFT + T", exec(ocrCmd))

hl.bind(SUPER .. " + SHIFT + C", exec("hyprpicker -a"))

hl.bind("Print", exec("grim - | wl-copy"), locked)
hl.bind(
	"CTRL + Print",
	exec(
		[[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && ]]
			.. [[grim $(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]
	),
	locked
)

local rec = home .. "/.config/quickshell/noctalia-shell/scripts/videos/record.sh"
hl.bind(SUPER .. " + SHIFT + R", exec(rec), locked)
hl.bind(SUPER .. " + ALT + R", exec(rec), locked)
hl.bind("CTRL + ALT + R", exec(rec .. " --fullscreen"), locked)
hl.bind(SUPER .. " + SHIFT + ALT + R", exec(rec .. " --fullscreen --sound"), locked)

hl.bind(
	SUPER .. " + SHIFT + ALT + mouse:273",
	exec(home .. "/.config/hypr/hyprland/scripts/ai/primary-buffer-query.sh"),
	{ mouse = true }
)

------------- WINDOW MANAGEMENT -------------
hl.bind(SUPER .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(SUPER .. " + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind(SUPER .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(SUPER .. " + Left", hl.dsp.focus({ direction = "l" }))
hl.bind(SUPER .. " + Right", hl.dsp.focus({ direction = "r" }))
hl.bind(SUPER .. " + Up", hl.dsp.focus({ direction = "u" }))
hl.bind(SUPER .. " + Down", hl.dsp.focus({ direction = "d" }))
hl.bind(SUPER .. " + BracketLeft", hl.dsp.focus({ direction = "l" }))
hl.bind(SUPER .. " + BracketRight", hl.dsp.focus({ direction = "r" }))

hl.bind(SUPER .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(SUPER .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(SUPER .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(SUPER .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))

hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(SUPER .. " + Q", hl.dsp.window.close())
hl.bind(SUPER .. " + SHIFT + ALT + Q", hl.dsp.window.kill())

-- splitratio: no dedicated Lua wrapper; use exec_raw for legacy dispatcher strings.
hl.bind(SUPER .. " + Semicolon", hl.dsp.exec_raw("splitratio -0.1"), { repeating = true })
hl.bind(SUPER .. " + Apostrophe", hl.dsp.exec_raw("splitratio +0.1"), { repeating = true })

hl.bind(SUPER .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(SUPER .. " + D", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(SUPER .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(SUPER .. " + ALT + D", hl.dsp.window.fullscreen_state({ internal = 0, client = 3 }))

------------- WORKSPACES (1..10 via raw keycodes) -------------
for i = 1, 10 do
	local key = (i % 10) -- 10 -> "0"
	hl.bind(SUPER .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
	hl.bind(SUPER .. " + ALT + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

hl.bind(SUPER .. " + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(SUPER .. " + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(SUPER .. " + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(SUPER .. " + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))

hl.bind(SUPER .. " + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(SUPER .. " + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(SUPER .. " + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(SUPER .. " + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "r-1" }))

hl.bind(SUPER .. " + ALT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind("CTRL + " .. SUPER .. " + S", hl.dsp.workspace.toggle_special("magic"))

-- Workspace switching
hl.bind("CTRL + " .. SUPER .. " + ALT + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CTRL + " .. SUPER .. " + ALT + Left", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(SUPER .. " + Page_Down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(SUPER .. " + Page_Up", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. SUPER .. " + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + " .. SUPER .. " + Page_Up", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(SUPER .. " + mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind(SUPER .. " + mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. SUPER .. " + mouse_up", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + " .. SUPER .. " + mouse_down", hl.dsp.focus({ workspace = "r-1" }))

hl.bind(SUPER .. " + S", hl.dsp.workspace.toggle_special())
hl.bind(SUPER .. " + mouse:275", hl.dsp.workspace.toggle_special())
hl.bind("CTRL + " .. SUPER .. " + BracketLeft", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. SUPER .. " + BracketRight", hl.dsp.focus({ workspace = "+1" }))
hl.bind("CTRL + " .. SUPER .. " + Up", hl.dsp.focus({ workspace = "r-5" }))
hl.bind("CTRL + " .. SUPER .. " + Down", hl.dsp.focus({ workspace = "r+5" }))

------------- VM SUBMAP -------------
-- notify + submap entry in one shell call. Lua-side hl.dsp.submap("virtual-machine")
-- works alone, but the notify needs to chain — hyprctl bridges both into one bind.
hl.bind(
	SUPER .. " + ALT + F1",
	exec(
		[[notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland' && hyprctl dispatch 'hl.dsp.submap("virtual-machine")']]
	)
)

------------- SESSION -------------
hl.bind(SUPER .. " + L", ipccmd({ "lockScreen", "lock" }))
hl.bind(SUPER .. " + SHIFT + L", exec("systemctl suspend || loginctl suspend"), locked)
hl.bind("CTRL + " .. SUPER .. " + L", ipccmd({ "sessionMenu", "lockAndSuspend" }))
hl.bind("CTRL + SHIFT + ALT + " .. SUPER .. " + Delete", exec("systemctl poweroff || loginctl poweroff"))

------------- ZOOM -------------
-- Monitor name must be resolved by the shell at press time, not by Lua at config load.
local focusedMonitor = [[$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')]]

hl.bind(SUPER .. " + Z", exec("woomer --monitor " .. focusedMonitor))

------------- MEDIA -------------
hl.bind(SUPER .. " + SHIFT + N", ipccmd({ "media", "next" }), locked)
hl.bind("XF86AudioNext", ipccmd({ "media", "next" }), locked)
hl.bind("XF86AudioPrev", ipccmd({ "media", "previous" }), locked)
hl.bind(SUPER .. " + SHIFT + B", ipccmd({ "media", "previous" }), locked)
hl.bind(SUPER .. " + SHIFT + P", ipccmd({ "media", "playPause" }), locked)
hl.bind("XF86AudioPlay", ipccmd({ "media", "playPause" }), locked)
hl.bind("XF86AudioPause", ipccmd({ "media", "playPause" }), locked)

------------- APP LAUNCHERS -------------
local laFA = home .. "/.config/hypr/hyprland/scripts/launch_first_available.sh"
local termList = [["${TERMINAL}" "kitty -1" "foot" "alacritty" "wezterm" "konsole" "kgx" "uxterm" "xterm"]]
local fileMgrList = [["nautilus" "nemo" "thunar" "${TERMINAL}" "kitty -1 fish -c yazi"]]
local editorList = [["code" "codium" "cursor" "zed" "zedit" "zeditor" "kate" "gnome-text-editor" "emacs"]]
local taskMgrList =
	[["gnome-system-monitor" "plasma-systemmonitor --page-name Processes" "command -v btop && kitty -1 fish -c btop"]]

hl.bind(SUPER .. " + Return", exec(laFA .. " " .. termList))
hl.bind(SUPER .. " + T", exec(laFA .. " " .. termList))
hl.bind("CTRL + ALT + T", exec(laFA .. " " .. termList))
hl.bind(SUPER .. " + E", exec(laFA .. " " .. fileMgrList))
hl.bind(SUPER .. " + C", exec(laFA .. " " .. editorList))
hl.bind("CTRL + " .. SUPER .. " + V", exec(laFA .. [[ "pavucontrol-qt" "pavucontrol"]]))
hl.bind(SUPER .. " + I", ipccmd({ "settings", "open" }))
hl.bind("CTRL + SHIFT + Escape", exec(laFA .. " " .. taskMgrList))

------------- MISC -------------
-- resizeactive percent form — hl.dsp.window.resize is numeric only; exec_raw passes the legacy string.
hl.bind("CTRL + " .. SUPER .. " + Backslash", hl.dsp.exec_raw("resizeactive exact 50% 60%"))

------------- PLUGINS -------------
-- hyprexpo plugin dispatcher — plugin-registered names go through exec_raw.
hl.bind(SUPER .. " + Tab", hl.dsp.exec_raw("hyprexpo:expo, toggle"))
