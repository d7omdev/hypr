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

hl.plugin({

	hyprfocus = {
		mode = "flash",
		only_on_monitor_change = false,
		fade_opacity = 0.8,
		bounce_strength = 0.95,
		slide_height = 20,
	},

	hyprexpo = {
		columns = 3,
		gaps_in = 5,
		gaps_out = 0,
		bg_col = "rgb(111111)",
		workspace_method = "center current",
		gesture_distance = 200,
		cancel_key = "escape",
		show_cursor = 1,
	},
})

if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass

	hg.config({
		enabled = false,
		default_theme = "dark",
		default_preset = "clear",
		tint_color = 0x8899aa22,
		brightness = 0.9,
		dark = { brightness = 0.82 },
		light = { adaptive_boost = 0.5 },

		layers = { enabled = 1 },
	})

	-- Layer surfaces: each call whitelists the namespace and configures it
	hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
	hg.layer("swaync")
	hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
	hg.layer("debug-panel", { exclude = true })

	-- Presets
	hg.preset("clear", {
		glass_opacity = 0.78,
		blur_strength = 0.1,
		blur_iterations = 4,
		refraction_strength = 0.3,
		chromatic_aberration = 0.6,
		fresnel_strength = 0.8,
		specular_strength = 0.9,
		-- lens_distortion = 0.7,
		edge_thickness = 0.08,

		dark = { brightness = 0.78, saturation = 0.7 },
		light = { brightness = 1.1, saturation = 0.8 },
	})

	hg.preset("contrasted", {
		inherits = "high_contrast",
		contrast = 1.2,
		adaptive_dim = 1.5,
		dark = { tint_color = 0x02142aa9 },
	})
end
