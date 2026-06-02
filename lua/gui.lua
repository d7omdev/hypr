-- HyprMod-managed overrides. Maps from hyprland-gui.conf.
-- Loaded LAST in entry chain so the GUI tool's settings win, matching the
-- old `source = hyprland-gui.conf` at the bottom of hyprland.conf.

-- Monitors (override the catch-all hl.monitor in lua/general.lua).
-- HDMI-A-1 60 Hz at 0x40, eDP-1 144 Hz at 1920x40. Color mgmt: cm srgb.
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x40", scale = 1, cm = "srgb" })
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "1920x40", scale = 1, cm = "srgb" })

hl.config({
	decoration = {
		blur = { popups = true },
	},
	ecosystem = {
		no_donation_nag = true,
	},
	general = {
		border_size = 2,
		-- Two-stop gradient at 79 degrees (hyprlang: `0xaa968f8d 0xffb4a4 79deg`).
		col = {
			active_border = { colors = { "0xaa968f8d", "0xffb4a4" }, angle = 79 },
		},
		snap = { border_overlap = true },
	},
	input = {
		follow_mouse = 1,
		touchpad = { middle_button_emulation = false },
	},
	misc = {
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
	},
})
