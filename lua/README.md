# Hyprland Lua config draft

Future migration target for Hyprland **0.55+** (where hyprlang is deprecated in favor of Lua).
Current system runs **0.54** — these files are **not loaded yet**.

## Layout

```
hyprland.lua.draft        # entry point (rename to hyprland.lua after upgrade)
lua/
├── env.lua               # hl.env(...)
├── execs.lua             # hl.on("hyprland.start", ...)
├── general.lua           # hl.config({ general/decoration/input/misc/... })
├── animations.lua        # hl.curve / hl.animation
├── rules.lua             # hl.window_rule / hl.layer_rule / hl.workspace_rule
├── colors.lua            # color overrides via hl.config
├── keybinds.lua          # hl.bind(keys, dispatcher, opts)
└── custom/               # user overrides — loaded last
    ├── env.lua
    ├── execs.lua
    ├── general.lua       # multi-monitor, scrolling layout, kb_layout=us,ara
    ├── rules.lua
    └── keybinds.lua
```

## Activation steps (after upgrading to 0.55+)

1. Back up current setup:
   `cp -r ~/.config/hypr ~/.config/hypr.hyprlang.bak`
2. Test in a nested session before swapping:
   `Hyprland -c $HOME/.config/hypr/hyprland.lua.draft`
3. If stable, rename:
   `mv ~/.config/hypr/hyprland.lua.draft ~/.config/hypr/hyprland.lua`
   and rename or remove `hyprland.conf` so Hyprland prefers the Lua entry.

## Known TODOs (search for `TODO:` in the files)

The official 0.55 example covers ~80% of cases. The following needed fallbacks
to `hl.dsp.exec_cmd("hyprctl dispatch ...")`:

- `submap` (VM keybind escape)
- `layoutmsg` (scrolling layout column ops)
- `splitratio`
- `fullscreen` / `fullscreenstate` / `pin` (likely have `hl.dsp.window.fullscreen`
  but not in the example yet)
- `forcekillactive`
- raw `code:NN` keys (used to dodge layout-dependent number keys)
- 4-finger up/down gestures with custom dispatcher targets
- plugin config blocks (`plugin:hyprfocus`, `plugin:hyprexpo`,
  `plugin:dynamic-cursors`, `plugin:hyprbars`)
- `bindd` / `bindp` flag equivalents (description for cheatsheet, on-press)

Fix these up while testing in a nested session — don't run on bare metal until
every TODO is resolved or the fallback proves stable.

## Notes on the API shape

- Settings: `hl.config({ section = { key = value, ... } })` — calls merge.
- Dispatchers are first-class: `hl.bind("SUPER + Q", hl.dsp.window.close())`.
- Bind opts replace flag suffixes:
  `bindm` → `{ mouse = true }`
  `bindl` → `{ locked = true }`
  `binde` → `{ repeating = true }`
  `bindle` → `{ locked = true, repeating = true }`
- Rules return a handle with `:set_enabled(false)` for runtime toggling.
