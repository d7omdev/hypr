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
		-- gap_size = 5,
		bg_col = "rgb(111111)",
		workspace_method = "center current",
	},

	hyprglass = {
		enabled = 1,
		blur_strength = 1,
		blur_iterations = 1,
		refraction_strength = 2.5,
		chromatic_aberration = 0.4,
		lens_distortion = 1,
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
	},
})
