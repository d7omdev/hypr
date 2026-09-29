# end4-pC quickshell freezes (2026-09-29)

## Symptom

`qs -c end4-pC` froze for several seconds at a time, many times an hour. Main thread
averaged 35% CPU over 3 h, RSS 1.3 GB with 320 MB in swap, and the instance log in
`/run/user/1000/quickshell/by-pid/<pid>/log.qslog` had grown to 319 MB (tmpfs, so RAM).

## Root cause

Two stacked problems.

1. **Quickshell watches the parents of every applications directory.**
   `src/core/desktopentrymonitor.cpp` (`addPathAndParents`) puts inotify watches on
   `/home/d7om`, `~/.local`, `~/.local/share`, `/usr/share`, `/usr` and `/`, not only on the
   `applications` folders. Any create/rename/delete directly in `$HOME` (shell history,
   `.claude.json`, browsers, editors) triggers a full `.desktop` rescan after a 100 ms
   debounce. The scan itself runs in a pool thread, but the result is applied on the GUI
   thread: every `DesktopEntry` object is rebuilt and `applicationsChanged` re-triggers the
   fuzzy-search index and every binding to `DesktopEntries.applications`. Upstream quickshell
   (HEAD 2026-09-25) still behaves this way.

2. **`XDG_DATA_DIRS` was duplicated 22 times.** `hyprland/env.lua` set it to the
   flatpak/usr dirs plus the *old* value, and Hyprland re-runs that on every config reload,
   so the list grew by four entries per reload. qs inherited 22 copies of the same four
   directories, so each rescan parsed ~11,000 files and created/destroyed ~11,000 QObjects
   instead of ~500. This also slowed every app Hyprland launches.

Evidence: unfiltered log (`qs log -r '*=true' <file>`) showed 431 rescans in 3 h with each
entry found 22 times per scan (9,545 hits for one entry). A single `touch` + `rm` of an empty
file in `$HOME` pegged the qs main thread at 100% for ~3 s, twice.

## Fixes applied

| Fix | Where | Effect |
|---|---|---|
| Dedupe `XDG_DATA_DIRS` | `hyprland/env.lua` | Rescan cost divided by 22. Verified: fresh qs sees each dir once. |
| Stop watching parent dirs, dedupe data dirs in quickshell | `patches/quickshell-desktopentry-no-parent-watch.patch`, wired into the illogical-impulse PKGBUILD (`pkgrel` 9) via `patches/illogical-impulse-quickshell-git-PKGBUILD.patch` | Removes the `$HOME` trigger entirely. |
| Overview `TypeError` spam and binding loop | `patches/end4-pC-overview-typeerrors.patch` | `OverviewWindow.qml` read `root.windowAddresses`, which only exists on the parent widget, so the tiled-count loop threw on every evaluation. Declared the lookups locally, made `size`/`at`/`reserved` reads null-safe, replaced the cross-file `window` id with `root`. `OptionsToolbar.qml` defers the selection-mode write with `Qt.callLater`. |
| Stop the constantly rotating desktop clock | `~/.config/illogical-impulse/config.json`, `background.widgets.clock.cookie.constantlyRotate = false` | Qt renders on the GUI thread here (no `QSGRenderThread`), so two 1080p background layers were redrawn continuously. Cuts idle main-thread load. |

Measured after the env fix and a qs restart (patched binary not yet installed): the same
`touch` + `rm` probe costs ~50% for ~1.5 s instead of 100% for ~6 s, and the log grows 11 KB
per event instead of ~780 KB.

## Reapplying on a fresh machine

1. `hyprland/env.lua` already contains the dedupe (tracked in this repo and in chezmoi).
2. QML fixes: `patches/apply.sh` picks up `end4-pC-overview-typeerrors.patch` with the others.
3. Quickshell: in the dots-hyprland checkout,
   `sdata/dist-arch/illogical-impulse-quickshell-git/`, apply
   `patches/illogical-impulse-quickshell-git-PKGBUILD.patch`, copy
   `patches/quickshell-desktopentry-no-parent-watch.patch` next to the PKGBUILD as
   `desktopentry-no-parent-watch.patch`, then `makepkg -f` and `sudo pacman -U` the result.
   The pinned upstream commit is `7511545`; the patch applies cleanly there.
4. Restart qs from Hyprland so it inherits the environment:
   `hyprctl dispatch "hl.dsp.exec_cmd('qs -c end4-pC')"`.

## Quick checks if it comes back

```sh
tr '\0' '\n' </proc/$(pgrep -x qs)/environ | grep XDG_DATA_DIRS | tr ':' '\n' | sort | uniq -c
ls -la /run/user/1000/quickshell/by-pid/$(pgrep -x qs)/log.qslog
qs log -r '*=true' -t 20000 /run/user/1000/quickshell/by-pid/$(pgrep -x qs)/log.qslog | grep -c 'Directory change detected'
```

## Still open

- Install the rebuilt package
  (`~/.cache/dots-hyprland/sdata/dist-arch/illogical-impulse-quickshell-git/illogical-impulse-quickshell-git-0.1.0.r1-9-x86_64.pkg.tar.zst`)
  and restart qs.
- Worth reporting upstream to quickshell: the parent-directory watch in
  `desktopentrymonitor.cpp`.
- qs baseline RSS is ~1.1 GB right after startup with this config (4K wallpapers, widgets,
  shaders). Not a leak, but large.
