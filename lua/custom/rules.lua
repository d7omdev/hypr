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
-- Blur is Noctalia-only: keep windows unblurred (was no_blur = false).
hl.window_rule({ name = "kitty-blur", match = { class = "^(kitty)$" }, no_blur = true })
hl.window_rule({ name = "zen-blur", match = { class = "^(zen)$" }, no_blur = true })

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

-- end4-pC (quickshell) panels — native-blur glass, mirroring the Noctalia
-- recipe above (blur + ignore_alpha) rather than hyprglass. The base
-- hyprland/rules.lua deliberately applies NO blur to these ("Noctalia-only"),
-- so this override opts each bounded panel back in.
--
-- `ignore_alpha` is the key piece and its semantics are the whole trick:
-- Hyprland renders blur ONLY behind pixels whose alpha is ABOVE this threshold
-- (content at/below it is treated as pass-through, no blur). The panel fills
-- are ~0.3 alpha (illogical-impulse transparency 0.7), so the threshold must
-- sit BELOW 0.3 — hence 0.15. An earlier attempt at 0.4 blurred the multi-layer
-- bar (effective alpha > 0.4) but NOT the single-rectangle 0.3 dock, which was
-- the tell. `blur = true` alone (no ignore_alpha) also showed nothing.
-- overview (the app launcher) is included below: it's fullscreen but MASKED to
-- its panel region, so native blur frosts only the launcher. Still excluded:
-- settings/session (fullscreen, unmasked → would blur the whole screen),
-- wallpaperSelector, polkit, regionSelector (blur pointless/harmful there).
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
	-- overview = the app search launcher too. Fullscreen layer but masked to
	-- its columnLayout (mask: Region { item: columnLayout }), so native blur
	-- frosts only the launcher panel, not the whole screen. Safe with native
	-- blur (the earlier exclusion was a hyprglass-input-trap concern, N/A here).
	"quickshell:overview",
}) do
	hl.layer_rule({ name = "qs-glass-blur-" .. ns, match = { namespace = ns }, blur = true })
	hl.layer_rule({ name = "qs-glass-alpha-" .. ns, match = { namespace = ns }, ignore_alpha = 0.15 })
end

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
