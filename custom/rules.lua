-- Custom window/layer rules. Loaded after hyprland/rules.lua, so these win.

-- ######## Window rules ########

hl.window_rule({ name = "float-clipse-gui", match = { title = "^(Clipse GUI)$" }, float = true })
hl.window_rule({
	name = "soundcore-control",
	match = { title = "^(Soundcore Control)$" },
	float = true,
	center = true,
	size = { 531, 850 },
})
hl.window_rule({
	name = "float-blueman",
	match = { class = "^(blueman-manager)$" },
	float = true,
	size = "monitor_w*0.30 monitor_h*0.50",
})

hl.window_rule({
	name = "scrcpy",
	match = { class = "^(scrcpy)$" },
	float = true,
})

hl.window_rule({ name = "clipse-border", match = { class = "^(clipse)$" }, border_size = 2 })

hl.window_rule({
	name = "ente-auth",
	match = { title = "^(Ente Auth)$", class = "io.ente.auth" },
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
	size = "monitor_w*0.30 monitor_h*0.65",
})

-- Automated/devtools Chrome: never yank focus or pull its workspace forward.
hl.window_rule({
	name = "chrome-no-steal-focus",
	match = { class = "^(google-chrome)$" },
	suppress_event = "activate activatefocus",
})

-- Workspace assignments
hl.window_rule({ name = "ws-spotify", match = { class = "^(Spotify)$" }, workspace = "10" })
hl.window_rule({ name = "ws-postman", match = { class = "^(Postman)$" }, workspace = "4" })
hl.window_rule({ name = "ws-teams", match = { class = "^(teams-for-linux)$" }, workspace = "3" })

-- Redundant with hyprland/rules.lua's catch-all `no_blur` on class ".*", but
-- kept explicit so these two stay unblurred if that catch-all is ever narrowed.
hl.window_rule({ name = "kitty-blur", match = { class = "^(kitty)$" }, no_blur = true })
hl.window_rule({ name = "zen-blur", match = { class = "^(zen)$" }, no_blur = true })

-- Openscreen presentation mode. Strips borders/rounding/blur from every window;
-- starts disabled and is toggled at runtime via the rule handle.
local openscreenRule = hl.window_rule({
	name = "openscreen",
	match = { class = ".*" },
	border_size = 0,
	rounding = 0,
	no_blur = true,
})
openscreenRule:set_enabled(false)

-- ######## Layer rules ########

-- Language-switch OSD (end4-pC LanguageOsd.qml). Deliberately uses a
-- non-"quickshell:" namespace. Override the
-- global xray = true from hyprland/rules.lua so it's a plain opaque pill.
hl.layer_rule({ name = "osd-language-noxray", match = { namespace = "osdLanguage" }, xray = false })
