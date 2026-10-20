-- Custom keybinds. Maps from custom/keybinds.conf.

local home  = os.getenv("HOME")
local SUPER = "SUPER"
local exec  = function(c) return hl.dsp.exec_cmd(c) end

-- USER
hl.bind("CTRL + " .. SUPER .. " + Slash",       exec("kitty -e nvim " .. home .. "/.config/illogical-impulse/config.json"))
hl.bind("CTRL + " .. SUPER .. " + ALT + Slash", exec("xdg-open " .. home .. "/.config/hypr/custom/keybinds.conf"))

-- APPS
hl.bind(SUPER .. " + V",         exec("clipse-gui"))
hl.bind(SUPER .. " + W",         exec("__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia zen-browser"))
hl.bind(SUPER .. " + SHIFT + F", exec("figma-linux"))
hl.bind(SUPER .. " + SHIFT + I", exec([[XDG_CURRENT_DESKTOP="gnome" gnome-control-center]]))

-- WINDOW
hl.bind(SUPER .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind("CTRL + " .. SUPER .. " + S",
    hl.dsp.window.move({ workspace = "special" }))
hl.bind(SUPER .. " + SHIFT + D", exec("pkill -SIGUSR1 wayscriber"))

-- MEDIA (mouse + key combos)
local locked    = { locked = true }
local lockedRep = { locked = true, repeating = true }

hl.bind("CTRL + mouse:275", exec("playerctl previous"), locked)
hl.bind("CTRL + mouse:276",
    exec([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]),
    locked)

hl.bind("CTRL + XF86AudioRaiseVolume", exec("playerctl next"),         lockedRep)
hl.bind("CTRL + XF86AudioLowerVolume", exec("playerctl previous"),     lockedRep)
hl.bind("ALT + XF86AudioRaiseVolume",  exec("playerctl position 2+"),  lockedRep)
hl.bind("ALT + XF86AudioLowerVolume",  exec("playerctl position 2-"),  lockedRep)
hl.bind("CTRL + XF86AudioMute",        exec("playerctl play-pause"),   lockedRep)

-- Cursor zoom (uses jq math)
hl.bind(SUPER .. " + CTRL + Up",
    exec([[hyprctl keyword cursor:zoom_factor $(hyprctl -j getoption cursor:zoom_factor | jq -r '.float * (2 | sqrt)')]]))
hl.bind(SUPER .. " + CTRL + Down",
    exec([[hyprctl keyword cursor:zoom_factor $(hyprctl -j getoption cursor:zoom_factor | jq -r '[.float / (2 | sqrt), 1] | max')]]))
hl.bind(SUPER .. " + mouse:274", exec("hyprctl keyword cursor:zoom_factor 1"), { mouse = true })

hl.bind(SUPER .. " + CTRL + E", exec("HYPRSHOT_EDITOR=1 quickshell -c HyprQuickFrame -n"))
hl.bind("ALT + Tab", exec("hypr-alttab"))

-- Scrolling layout dispatchers — hl.dsp.layout(msg) per scrolling layout docs.
hl.bind(SUPER .. " + CTRL + Left",      hl.dsp.layout("colresize -0.1"))
hl.bind(SUPER .. " + CTRL + Right",     hl.dsp.layout("colresize +0.1"))
hl.bind(SUPER .. " + CTRL + C",         hl.dsp.layout("alignwindow c"))
hl.bind(SUPER .. " + CTRL + H",         hl.dsp.layout("admitwindow"))
hl.bind(SUPER .. " + CTRL + X",         hl.dsp.layout("expelwindow"))
hl.bind(SUPER .. " + SHIFT + Period",   hl.dsp.layout("move +col"))
hl.bind(SUPER .. " + SHIFT + Comma",    hl.dsp.layout("move -col"))
hl.bind(SUPER .. " + CTRL + Period",    hl.dsp.layout("swapcol r"))
hl.bind(SUPER .. " + CTRL + Comma",     hl.dsp.layout("swapcol l"))
