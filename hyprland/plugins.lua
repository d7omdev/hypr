-- Plugin settings.
-- hl.plugin() is a callable wrapper around hl.config that produces
-- dot-separated keys (e.g. plugin.hyprfocus.enabled) matching the
-- Lua config manager's internal name normalization (colons→dots, hyphens→_).
-- Hyprpm is expected to load the .so files — these calls configure them.

setmetatable(hl.plugin, {
	__call = function(_, config)
		local function norm(t)
			local r = {}
			for k, v in pairs(t) do
				local nk = type(k) == "string" and (k:gsub("-", "_")) or k
				r[nk] = type(v) == "table" and norm(v) or v
			end
			return r
		end
		return hl.config({ plugin = norm(config) })
	end,
})

-- hl.plugin({
-- 	hyprfocus = {
-- 		mode = "flash",
-- 		only_on_monitor_change = false,
-- 		fade_opacity = 0.8,
-- 		bounce_strength = 0.95,
-- 		slide_height = 20,
-- 	},
-- })

-- hyprexpo disabled: conflicts with scrolloverview (both hook Hyprland's
-- shared overview API — only one can own it at a time).

-- ─── hyprglass (Liquid Glass, by Hyprnux) ───────────────────────────────
-- Configured via the plugin's own `hg` API (hl.plugin.hyprglass), which is
-- auto-injected once hyprpm has loaded the .so. The guard keeps the config
-- valid if the plugin isn't loaded yet (no crash, just no glass).
--
-- Layer surfaces are OFF by default and use EXACT full-string namespace
-- matching (std::set::contains in main.cpp) — no regex, no substring. Each
-- monitor has its own namespace suffix, so both must be listed explicitly.
-- Get live namespaces with:  hyprctl layers | grep noctalia
if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass

	hg.config({
		enabled = true,
		blur_strength = 0.8,
		blur_iterations = 1,
		refraction_strength = 2.5,
		chromatic_aberration = 0.4,
		lens_distortion = 0.5,
		edge_thickness = 0.018,
		fresnel_strength = 1,
		specular_strength = 1,
		tint_color = 0x00000000,
		glass_opacity = 1,
		brightness = 1,
		contrast = 1.0,
		saturation = 1.0,
		vibrancy = 0.0,
		adaptive_dim = 0.0,
		adaptive_boost = 0.0,

		-- ⚠️ Layer glass DISABLED — and should stay off.
		-- All Noctalia popups are drawn inside ONE fullscreen PanelWindow
		-- (`noctalia-background-<screen>`, MainScreen.qml) that also owns keyboard
		-- focus. Glassing it could full-screen-blur AND trap input, making the
		-- session inaccessible (this happened). hyprglass WINDOW glass is unaffected
		-- and still works. The hg.layer() lines below are INERT while this is false;
		-- they are kept only as notes for anyone who wants to retry layer glass.
		layers = { enabled = true },
	})

	-- ↓↓↓ INERT while layers.enabled = false above. Do not re-enable layer glass
	-- without understanding the fullscreen-panel-host lockout risk described above.
	local PANEL_MASK = 0.25
	hg.layer("noctalia-background-eDP-1", { mask_threshold = PANEL_MASK })
	hg.layer("noctalia-background-HDMI-A-1", { mask_threshold = PANEL_MASK })
	hg.layer("noctalia-bar-content-eDP-1")
	hg.layer("noctalia-bar-content-HDMI-A-1")
	hg.layer("noctalia-dock-peek-eDP-1")
end
