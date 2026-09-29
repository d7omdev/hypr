local home_dir = os.getenv("HOME")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Applications
-- Deduplicated: this file re-runs on every reload and the old value already
-- contains these entries, so plain prepending grows the list without bound.
local xdg_data_dirs, seen = {}, {}
for dir in (home_dir .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" .. (os.getenv("XDG_DATA_DIRS") or "")):gmatch("[^:]+") do
	if not seen[dir] then
		seen[dir] = true
		xdg_data_dirs[#xdg_data_dirs + 1] = dir
	end
end
hl.env("XDG_DATA_DIRS", table.concat(xdg_data_dirs, ":"))

-- Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- Virtual environment
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")
