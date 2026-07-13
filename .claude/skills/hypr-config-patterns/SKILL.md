---
name: hypr-config-patterns
description: Use when editing this Hyprland dotfiles repo (d7omdev/hypr) — covers the Lua config API (hl.*), the base + custom/ override layering, the edit→reload→configerrors verification loop, and the automated commit bot. Invoke before changing window/layer rules, keybinds, exec, or settings.
version: 1.0.0
source: local-git-analysis
analyzed_commits: 138
---

# Hypr Config Patterns (d7omdev/hypr)

Personal Hyprland dotfiles, mid-migration from hyprlang `.conf` to the **Lua config system** (Hyprland 0.55+ `hl` API). Lua is the live config — the `lua/README.md` claim that "files are not loaded yet" is **stale**; `hyprland.lua` is the active entrypoint.

## Architecture

```
hyprland.lua            # LIVE entrypoint — sets package.path, require()s lua/ in order
lua/
├── env.lua             # hl.env(...)
├── execs.lua           # hl.on("hyprland.start", ...) autostart
├── general.lua         # hl.config({ general/decoration/input/misc/... }); BLUR toggle
├── animations.lua      # hl.curve / hl.animation
├── rules.lua           # hl.window_rule / hl.layer_rule / hl.workspace_rule  ← hottest file
├── colors.lua          # color overrides
├── keybinds.lua        # hl.bind(keys, dispatcher, opts)
├── plugins.lua         # hl.plugin({...}) — hyprfocus, hyprexpo, hyprglass (Liquid Glass)
├── gui.lua             # HyprMod-managed overrides — loaded LAST so the tool wins
└── custom/             # USER OVERRIDES — required LAST, after the matching base file
    ├── env.lua  execs.lua  general.lua  rules.lua  keybinds.lua
hyprland/               # LEGACY hyprlang .conf (migration source, not loaded)
custom/                 # LEGACY custom .conf overrides
hyprlock.conf hypridle.conf hyprshot.conf  # standalone hyprlang tools (NOT migrated)
```

**Override layering (the core convention):** base file loads first, `custom/<same-name>` loads last and wins. Personal/machine-specific tweaks go in `lua/custom/`, never in the base `lua/` files. This mirrors the old `hyprland/*.conf` + `custom/*.conf` split.

## The `hl` Lua API

Stubbed at `/usr/share/hypr/stubs/hl.meta.lua` (registered as a workspace library in `.luarc.json`). Key shapes:

- **Settings:** `hl.config({ section = { key = value } })` — calls merge.
- **Rules:** `hl.window_rule({ name=, match={...}, <prop>=value })`, `hl.layer_rule(...)`, `hl.workspace_rule(...)`. Returns a handle with `:set_enabled(false)` for runtime toggling.
- **Binds:** `hl.bind("SUPER + Q", hl.dsp.window.close())`. Dispatchers are first-class (`hl.dsp.*`). Bind opts replace flag suffixes: `{mouse=true}`=bindm, `{locked=true}`=bindl, `{repeating=true}`=binde.
- **Autostart:** `hl.on("hyprland.start", ...)`.
- **Plugins:** `hl.plugin({ name = {...} })` — normalizes hyphens→underscores; hyprpm loads the `.so`.

### Rule `match` keys — curated allowlist, snake_case (CRITICAL)

`match` is NOT a raw Hyprland-selector passthrough. The wrapper rejects unknown keys with `hl.window_rule: unknown match property 'X'` (surfaced via `hyprctl configerrors`, not the reload exit code). Known-good keys observed:

| match key | maps to Hyprland selector | notes |
|-----------|---------------------------|-------|
| `class`   | `class:`        | regex, e.g. `"^(zen)$"` |
| `title`   | `title:`        | **dynamic** — changes as window updates |
| `initial_title` | `initialtitle:` | snake_case; immutable at map-time. NOT `initialtitle` |
| `initial_class` | `initialclass:` | snake_case |
| `namespace` | (layer rules)  | for `layer_rule` |
| `float`   | `floating:0/1`  | friendly alias — `float = true/false` |

Props are also snake_case: `no_blur`, `no_initial_focus`, `keep_aspect_ratio`, `border_size`, `no_shadow`, `move`, `size` (supports `monitor_w*0.30 monitor_h*0.50`).

**Lesson learned:** to distinguish two windows of the same `class` (e.g. two Zen windows from one PID), match on `initial_title` (immutable), never live `title`. `float` is a static rule applied at window open, so the selector must key off a map-time attribute.

## Verification Loop (always run after a Lua edit)

```bash
hyprctl reload            # returns "ok" even when individual rules are rejected
hyprctl configerrors      # the REAL oracle — shows per-rule rejections
```

`hyprctl reload` exit 0 is not sufficient proof; a bad `match` key still reloads "ok". Always check `configerrors`. To inspect live windows for a selector: `hyprctl clients -j` (fields `class`, `initialClass`, `initialTitle`, `title`, `floating`).

Theme/visual changes (`liquid glass`, noctalia) note: blur is **Noctalia-only**, owned by the hyprglass plugin; native `decoration:blur` rules are intentionally avoided. `BLUR=true` in `lua/general.lua` must stay on so hyprglass's renderer has the blur engine.

## Commit Conventions

History is mixed (138 commits):

- **~60% automated bot** — `auto-commit-push.sh` runs on a schedule, stages everything except `logs/`, commits `"Automated commit and push on <date> by script\nChanged files:\n..."`, pushes `main`. Do not imitate this format for manual commits.
- **~15% conventional** — `feat(scope):`, `fix:`, `chore:` (e.g. `feat(hyprland): update theme...`). **Prefer this for manual commits.**
- Remainder are terse (`Update`, `state:02/06`, `layer rules`). Avoid these.

For manual work here: use conventional commits, scope by area (`hyprland`, `config`, `scripts`). Per global prefs: no Co-Authored-By attribution. Commit/push only when asked — the bot handles routine syncing.

## Common Workflows

### Add a window/layer rule
1. Edit `lua/custom/rules.lua` (personal) — base rules live in `lua/rules.lua`.
2. Use snake_case `match` keys from the allowlist above; give every rule a `name`.
3. `hyprctl reload && hyprctl configerrors` — fix any `unknown match property`.
4. Confirm against a live window via `hyprctl clients -j`.

### Add a keybind
1. Edit `lua/custom/keybinds.lua`; `hl.bind("MOD + KEY", hl.dsp.<...>(), opts)`.
2. Reload + configerrors.

### Toggle a rule at runtime
`local r = hl.window_rule({...}); r:set_enabled(false)` — used for the openscreen presentation-mode rule.
