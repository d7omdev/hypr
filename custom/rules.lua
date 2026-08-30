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

-- Noctalia background
hl.layer_rule({ name = "noctalia-bg-blur", match = { namespace = "noctalia-background-.*" }, blur = true })
hl.layer_rule({ name = "noctalia-bg-popups", match = { namespace = "noctalia-background-.*" }, blur_popups = true })
hl.layer_rule({ name = "noctalia-bg-alpha", match = { namespace = "noctalia-background-.*" }, ignore_alpha = 0.8 })

-- end4-pC (quickshell) panels — native-blur glass.
--
-- hyprland/rules.lua already blurs `quickshell:.*` wholesale at
-- ignore_alpha = 0.79. That threshold is far too HIGH for these panels, so the
-- loop below re-declares each bounded panel at 0.15.
--
-- `ignore_alpha` semantics are the whole trick: Hyprland renders blur ONLY
-- behind pixels whose alpha is ABOVE this threshold (content at/below it is
-- treated as pass-through, no blur). The panel fills are ~0.3 alpha
-- (illogical-impulse transparency 0.7), so the threshold must sit BELOW 0.3 —
-- hence 0.15, and why the inherited 0.79 renders nothing. An earlier attempt at
-- 0.4 blurred the multi-layer bar (effective alpha > 0.4) but NOT the
-- single-rectangle 0.3 dock, which was the tell. `blur = true` alone (no
-- ignore_alpha) also showed nothing.
--
-- Fullscreen layers are safe to include ONLY when their backdrop is fully
-- transparent and their content is masked to a bounded card — ignore_alpha then
-- bounds the blur to the card. That covers overview, settings, cheatsheet and
-- wallpaperSelector (all `color: "transparent"` + a Region mask).
-- Still EXCLUDED: session (fullscreen with an opaque dim → would blur the whole
-- screen), polkit and regionSelector (blur pointless/harmful there).
for _, ns in ipairs({
	"quickshell:bar",
	"quickshell:verticalBar",
	"quickshell:dock",
	"quickshell:sidebarLeft",
	"quickshell:sidebarRight",
	"quickshell:notificationPopup",
	"quickshell:onScreenDisplay",
	"quickshell:mediaControls",
	"quickshell:popup",
	"quickshell:overview",
	"quickshell:settings",
	"quickshell:cheatsheet",
	-- Thumbnails here are opaque (>0.15) so their blur is hidden under them.
	"quickshell:wallpaperSelector",
}) do
	hl.layer_rule({ name = "qs-glass-blur-" .. ns, match = { namespace = ns }, blur = true })
	hl.layer_rule({ name = "qs-glass-alpha-" .. ns, match = { namespace = ns }, ignore_alpha = 0.15 })
end

-- Language-switch OSD (end4-pC LanguageOsd.qml). Deliberately uses a
-- non-"quickshell:" namespace so it escapes the glass rules above. Override the
-- global xray = true from hyprland/rules.lua so it's a plain opaque pill.
hl.layer_rule({ name = "osd-language-noxray", match = { namespace = "osdLanguage" }, xray = false })
