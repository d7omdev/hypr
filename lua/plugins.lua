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
})
