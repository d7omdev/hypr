-- Window rules + layer rules + workspace rules.
-- Maps from hyprland/rules.conf.
-- API:
--   hl.window_rule({ name = "...", match = { class=, title=, float=, ... }, <prop>=value })
--   hl.layer_rule({  name = "...", match = { namespace = "..." }, <prop>=value })
--   hl.workspace_rule({ workspace = "...", gaps_out=, gaps_in=, ... })

------------- WINDOW RULES -------------

-- No blur globally; old config used `match:class .*, no_blur on`
hl.window_rule({
	name = "no-blur-default",
	match = { class = ".*" },
	no_blur = true,
})

-- File dialogs: float + center
local fileDialogTitles = {
	"^(Open File)(.*)$",
	"^(Select a File)(.*)$",
	"^(Open Folder)(.*)$",
	"^(Save As)(.*)$",
	"^(Library)(.*)$",
	"^(File Upload)(.*)$",
	"^(.*)(wants to save)$",
	"^(.*)(wants to open)$",
}
for _, t in ipairs(fileDialogTitles) do
	hl.window_rule({
		name = "float-dialog-" .. t,
		match = { title = t },
		float = true,
		center = true,
	})
end

-- Wallpaper picker
hl.window_rule({
	name = "wallpaper-picker",
	match = { title = "^(Choose wallpaper)(.*)$" },
	float = true,
	center = true,
	size = "monitor_w*0.60 monitor_h*0.65",
})

-- Settings / utility windows
hl.window_rule({ name = "float-blueberry", match = { class = "^(blueberry%.py)$" }, float = true })
hl.window_rule({ name = "float-guifetch", match = { class = "^(guifetch)$" }, float = true })

-- pavucontrol family
for _, c in ipairs({ "^(pavucontrol)$", "^(org.pulseaudio.pavucontrol)$", "^(nm-connection-editor)$" }) do
	hl.window_rule({
		name = "float-" .. c,
		match = { class = c },
		float = true,
		center = true,
		size = "monitor_w*0.45 monitor_h*0.45",
	})
end

hl.window_rule({ name = "float-plasmawindowed", match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ name = "float-kcm", match = { class = "kcm_.*" }, float = true })
hl.window_rule({ name = "float-bluedevil", match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ name = "float-welcome", match = { title = ".*Welcome" }, float = true })
hl.window_rule({ name = "float-ii-settings", match = { title = "^(illogical-impulse Settings)$" }, float = true })
hl.window_rule({ name = "float-shell-conflict", match = { title = ".*Shell conflicts.*" }, float = true })

hl.window_rule({
	name = "float-portal-kde",
	match = { class = "org.freedesktop.impl.portal.desktop.kde" },
	float = true,
	size = "monitor_w*0.60 monitor_h*0.65",
})

hl.window_rule({
	name = "float-zotero",
	match = { class = "^(Zotero)$" },
	float = true,
	size = "monitor_w*0.45 monitor_h*0.45",
})

-- Move offscreen (kde-material-you-colors helper)
hl.window_rule({
	name = "hide-plasma-changeicons",
	match = { class = "^(plasma-changeicons)$" },
	float = true,
	no_initial_focus = true,
	move = "999999 999999",
})

-- Dolphin copy reposition
hl.window_rule({
	name = "dolphin-copy-pos",
	match = { title = "^(Copying — Dolphin)$" },
	move = "40 80",
})

-- Tile Warp terminal
hl.window_rule({
	name = "tile-warp",
	match = { class = "^dev%.warp%.Warp$" },
	tile = true,
})

-- Picture-in-Picture
hl.window_rule({
	name = "pip",
	match = { title = "^([Pp]icture[-%s]?[Ii]n[-%s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = "monitor_w*0.73 monitor_h*0.72",
	size = "monitor_w*0.25 monitor_h*0.25",
})

-- Tearing for games / wine
hl.window_rule({ name = "tear-exe", match = { title = ".*%.exe" }, immediate = true })
hl.window_rule({ name = "tear-minecraft", match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ name = "tear-steam", match = { class = "^(steam_app).*" }, immediate = true })

-- JetBrains focus glitch fix
hl.window_rule({
	name = "fix-jetbrains-focus",
	match = { class = "^jetbrains%-.*$", float = true, title = "^$|^%s$|^win%d+$" },
	no_initial_focus = true,
})

-- No shadow on tiled windows
hl.window_rule({
	name = "no-shadow-tiled",
	match = { float = false },
	no_shadow = true,
})

------------- WORKSPACE RULES -------------

hl.workspace_rule({ workspace = "special:special", gaps_out = 1 })

------------- LAYER RULES -------------

-- xray on everything
hl.layer_rule({ name = "xray-all", match = { namespace = ".*" }, xray = true })

-- no-anim launchers
for _, ns in ipairs({ "walker", "selection", "overview", "anyrun", "indicator.*", "osk", "hyprpicker", "noanim" }) do
	hl.layer_rule({ name = "no-anim-" .. ns, match = { namespace = ns }, no_anim = true })
end

-- gtk-layer-shell (blur intentionally NOT applied — blur is Noctalia-only)
hl.layer_rule({ name = "no-anim-gtk4ls", match = { namespace = "gtk4-layer-shell" }, no_anim = true })

-- NOTE: The old illogical-impulse/ags `blurredLayers` blur block was removed.
-- Blur is now Noctalia-only and controlled by the BLUR toggle in lua/general.lua.

-- ags slide directions
hl.layer_rule({ name = "slide-l-sideleft", match = { namespace = "sideleft.*" }, animation = "slide left" })
hl.layer_rule({ name = "slide-r-sideright", match = { namespace = "sideright.*" }, animation = "slide right" })

-- Quickshell (illogical-impulse) — blur intentionally NOT applied (Noctalia-only)
hl.layer_rule({ name = "qs-bar-slide", match = { namespace = "quickshell:bar" }, animation = "slide" })
hl.layer_rule({ name = "qs-actioncenter", match = { namespace = "quickshell:actionCenter" }, no_anim = true })
hl.layer_rule({ name = "qs-cheatsheet", match = { namespace = "quickshell:cheatsheet" }, animation = "slide bottom" })
hl.layer_rule({ name = "qs-dock", match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({
	name = "qs-screenCorners",
	match = { namespace = "quickshell:screenCorners" },
	animation = "popin 120%",
})
hl.layer_rule({ name = "qs-lockpusher", match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })
hl.layer_rule({ name = "qs-notifpop", match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({
	name = "qs-overlay-noanim",
	match = { namespace = "quickshell:overlay" },
	no_anim = true,
	ignore_alpha = 1,
})
hl.layer_rule({ name = "qs-overview", match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({
	name = "qs-osk-bottom",
	match = { namespace = "quickshell:osk" },
	animation = "slide bottom",
	order = -1,
})
hl.layer_rule({ name = "qs-polkit", match = { namespace = "quickshell:polkit" }, no_anim = true })
hl.layer_rule({ name = "qs-popup", match = { namespace = "quickshell:popup" }, xray = false, ignore_alpha = 1 })
hl.layer_rule({ name = "qs-mediaCtrl", match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1 })
hl.layer_rule({ name = "qs-reload", match = { namespace = "quickshell:reloadPopup" }, animation = "slide" })
hl.layer_rule({ name = "qs-region", match = { namespace = "quickshell:regionSelector" }, no_anim = true })
hl.layer_rule({ name = "qs-screenshot", match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({
	name = "qs-session",
	match = { namespace = "quickshell:session" },
	no_anim = true,
})
hl.layer_rule({ name = "qs-sidebarR", match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ name = "qs-sidebarL", match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
hl.layer_rule({ name = "qs-vbar", match = { namespace = "quickshell:verticalBar" }, animation = "slide" })

-- Quickshell waffles
hl.layer_rule({
	name = "qs-wallpaperSel",
	match = { namespace = "quickshell:wallpaperSelector" },
	animation = "slide top",
})
for _, ns in ipairs({ "wNotificationCenter", "wOnScreenDisplay", "wStartMenu" }) do
	hl.layer_rule({
		name = "qs-waffles-" .. ns,
		match = { namespace = "quickshell:" .. ns },
		no_anim = true,
	})
end
hl.layer_rule({
	name = "qs-wTaskView",
	match = { namespace = "quickshell:wTaskView" },
	no_anim = true,
	ignore_alpha = 0,
})

-- Noctalia glass is owned ENTIRELY by the hyprglass plugin (see lua/plugins.lua),
-- which whitelists exactly the surfaces we want glassed (panel host, bar, dock).
-- No native decoration:blur rules for Noctalia here — a native rule matching
-- notifications/osd was previously blurring those even though we don't want them.
-- (BLUR=true is still required so hyprglass's layer renderer has the blur engine.)
