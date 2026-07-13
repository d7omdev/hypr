-- Custom autostarts. Maps from custom/execs.conf.

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
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
	-- hyprpm reload is run early in lua/execs.lua (defaults). Don't re-run here.
	hl.exec_cmd("bash " .. home .. "/.config/hypr/scripts/float-google-signin.sh")
end)
