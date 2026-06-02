-- exec-once equivalents. All wrapped in hyprland.start event.
-- API: hl.on("hyprland.start", function() hl.exec_cmd(...) end)

local home = os.getenv("HOME")
local qsConfig = "noctalia-shell"

hl.on("hyprland.start", function()
	-- Plugins FIRST — hyprpm reload loads compiled plugins (.so) into the
	-- running compositor. Must precede anything that depends on plugin
	-- dispatchers/keywords (quickshell hyprbars buttons, hyprexpo binds, etc).
	hl.exec_cmd("sleep 10 && hyprpm reload")

	-- Bar / wallpaper
	hl.exec_cmd(home .. "/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")
	hl.exec_cmd("qs -c " .. qsConfig .. " &")
	hl.exec_cmd(home .. "/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")

	-- Core
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("dbus-update-activation-environment --all")
	hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

	-- Audio
	hl.exec_cmd("easyeffects --hide-window --service-mode")

	-- Cursor
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

	-- Submap reset (safety belt — no submap is active on a fresh start).
	hl.exec_cmd([[hyprctl dispatch 'hl.dsp.submap("reset")']])
end)
