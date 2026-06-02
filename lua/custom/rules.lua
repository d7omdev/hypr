-- Custom window/layer rules. Maps from custom/rules.conf.

hl.window_rule({ name = "float-clipse-gui", match = { title = "^(Clipse GUI)$" }, float = true })
hl.window_rule({
	name = "float-blueman",
	match = { class = "^(blueman-manager)$" },
	float = true,
	size = "monitor_w*0.30 monitor_h*0.50",
})
hl.window_rule({ name = "clipse-border", match = { class = "^(clipse)$" }, border_size = 2 })

-- Workspace assignments
hl.window_rule({ name = "ws-spotify", match = { class = "^(Spotify)$" }, workspace = "10" })
hl.window_rule({ name = "ws-postman", match = { class = "^(Postman)$" }, workspace = "4" })
hl.window_rule({ name = "ws-teams", match = { class = "^(teams-for-linux)$" }, workspace = "3" })
hl.window_rule({ name = "kitty-blur", match = { class = "^(kitty)$" }, no_blur = false })
hl.window_rule({ name = "zen-blur", match = { class = "^(zen)$" }, no_blur = false })

hl.window_rule({
	name = "ente-auth",
	match = { title = "^(Ente Auth)$" },
	float = true,
	size = "monitor_w*0.25 monitor_h*0.60",
})
hl.window_rule({ name = "float-share-picker", match = { class = "^(hyprland-share-picker)$" }, float = true })
hl.window_rule({ name = "float-kdec", match = { class = "^(org.kde.kdeconnect.daemon)$" }, float = true })

-- Google sign-in popup in Zen
hl.window_rule({
	name = "zen-google-signin",
	match = { class = "^(zen)$", title = "^(Sign in - Google Accounts)" },
	float = true,
	center = true,
	size = "monitor_w*0.40 monitor_h*0.70",
})

-- Noctalia background
hl.layer_rule({ name = "noctalia-bg-blur", match = { namespace = "noctalia-background-.*" }, blur = true })
hl.layer_rule({ name = "noctalia-bg-popups", match = { namespace = "noctalia-background-.*" }, blur_popups = true })
hl.layer_rule({ name = "noctalia-bg-alpha", match = { namespace = "noctalia-background-.*" }, ignore_alpha = 0.8 })

-- Openscreen presentation mode (toggleable via rule handle).
-- Original was a named windowrule with no selector, toggled from a script.
-- Lua: keep a handle, start disabled, toggle with openscreenRule:set_enabled(true/false).
local openscreenRule = hl.window_rule({
	name = "openscreen",
	match = { class = ".*" },
	border_size = 0,
	rounding = 0,
	no_blur = true,
})
openscreenRule:set_enabled(false)
