-- Custom general overrides. Maps from custom/general.conf.

-- Multi-monitor: explicit positions override the catch-all in lua/general.lua
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-2", mode = "1920x1080@120", position = "1920x0", scale = 1 })

hl.config({
	input = {
		kb_layout = "us,ara",
		kb_options = "grp:alt_shift_toggle",
		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 35,
		special_fallthrough = true,
		follow_mouse = 1,
		touchpad = {
			tap_to_click = true,
			natural_scroll = false,
			disable_while_typing = true,
			clickfinger_behavior = true,
			scroll_factor = 0.9,
		},
	},

	general = {
		layout = "scrolling",
	},

	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.95,
		direction = "right",
	},
})

-- Vicinae bind kept here because it lives next to its server exec
hl.bind("SUPER + Space", hl.dsp.exec_cmd("vicinae toggle"))
