-- General / decoration / input / misc / cursor / binds / dwindle / gestures.
-- Maps from hyprland/general.conf.
-- API: hl.config({ section = { key = value, ... } })

-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  BLUR MASTER TOGGLE — Hyprland's native decoration:blur engine.     │
-- │                                                                     │
-- │  Currently nothing relies on it for layers: hyprglass LAYER glass    │
-- │  is disabled (it could full-screen-blur and lock the session — see   │
-- │  lua/plugins.lua), and there are no native Noctalia blur rules.      │
-- │  hyprglass WINDOW glass is independent of this. Left ON as a no-op   │
-- │  safety; set false if you want the engine fully off.                 │
-- │  Reload after changing: CTRL+SUPER+R or `hyprctl reload`.            │
-- └─────────────────────────────────────────────────────────────────────┘
BLUR = false

-- Default monitor (overridden by custom/general.lua for multi-monitor setup)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 5,
		gaps_workspaces = 50,

		border_size = 1,
		col = {
			active_border = "rgba(0DB7D455)",
			inactive_border = "rgba(31313600)",
		},
		resize_on_border = true,

		no_focus_fallback = true,
		allow_tearing = true,

		snap = {
			enabled = true,
			window_gap = 4,
			monitor_gap = 5,
			respect_gaps = true,
		},
	},

	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = false,
	},

	decoration = {
		rounding = 20,
		rounding_power = 6,

		blur = {
			enabled = BLUR,
			xray = false,
			special = false,
			new_optimizations = true,
			size = 4,
			passes = 2,
			brightness = 1,
			noise = 0,
			contrast = 0.89,
			vibrancy = 0.5,
			vibrancy_darkness = 0.5,
			popups = true,
			popups_ignorealpha = 0.6,
			input_methods = true,
			input_methods_ignorealpha = 0.8,
		},

		shadow = {
			enabled = true,
			range = 50,
			offset = "0 4",
			render_power = 10,
			color = "rgba(00000027)",
		},

		dim_inactive = true,
		dim_strength = 0.05,
		dim_special = 0.2,
	},

	input = {
		kb_layout = "us",
		numlock_by_default = true,
		repeat_delay = 250,
		repeat_rate = 35,
		follow_mouse = 1,
		off_window_axis_events = 2,
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			scroll_factor = 0.7,
		},
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 1,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot|kitty|allacritty|Alacritty|noctalia)",
		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,
		session_lock_xray = true,
		initial_workspace_tracking = false,
		focus_on_activate = true,
	},

	binds = {
		scroll_event_delay = 0,
		hide_special_on_workspace_change = true,
	},

	cursor = {
		zoom_factor = 1,
		zoom_rigid = false,
		zoom_disable_aa = true,
		hotspot_padding = 1,
	},
})

-- Gestures (functional API per example)
hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
hl.gesture({ fingers = 3, direction = "pinch", action = "float" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
-- TODO: 4-finger up/down → quickshell global dispatchers. Need 0.55 gesture API
-- for arbitrary dispatcher targets. Original:
--   gesture = 4, up,   dispatcher, global, quickshell:overviewWorkspacesToggle
--   gesture = 4, down, dispatcher, global, quickshell:overviewWorkspacesClose

hl.config({
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
})

-- Plugin settings (plugin:hyprfocus, plugin:dynamic-cursors, plugin:hyprexpo).
-- Lua plugin-config shape (confirmed via hyprland-plugins/hyprbars/README.md):
--   hl.config({ ["plugin:hyprfocus"] = { ... } })
-- Translate the original hyprlang `plugin { hyprfocus { ... } }` blocks here
-- when plugins are loaded via `hyprpm`. Keybinds live in keybinds.lua.
