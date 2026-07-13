-- Custom autostarts. Maps from custom/execs.conf.

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
	-- Load hyprpm-managed plugins (.so) into the running compositor. This is the
	-- ONLY place it runs: hyprland.lua loads hyprland/execs.lua (which has no
	-- hyprpm reload) + this custom file — it never loads lua/execs.lua, so the
	-- reload that file's comment referred to never actually fired.
	-- Two passes: a single early reload occasionally loads only a subset of the
	-- enabled plugins (a race with compositor/input readiness). The second pass
	-- is idempotent (only loads MISSING plugins); `-n` gives a success toast and
	-- warnings/errors notify regardless.
	hl.exec_cmd("sleep 8 && hyprpm reload; sleep 4 && hyprpm reload -n")

	hl.exec_cmd("swww-daemon --format xrgb")
	hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent & gammastep")
	hl.exec_cmd("vicinae server")

	hl.exec_cmd([[tmux setenv -g HYPRLAND_INSTANCE_SIGNATURE "$HYPRLAND_INSTANCE_SIGNATURE"]])

	-- Clipboard history (clipse)
	hl.exec_cmd("wl-paste --watch clipse store &")
	hl.exec_cmd("wl-paste --type text --watch clipse store")
	hl.exec_cmd("wl-paste --type image --watch clipse store")
	hl.exec_cmd("clipse -listen")

	hl.exec_cmd("kdeconnect-indicator")
	hl.exec_cmd("bash " .. home .. "/.config/hypr/scripts/float-google-signin.sh")
end)
