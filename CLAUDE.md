# CLAUDE.md

## What this is

A KDE Plasma 6 KWin script (plain JavaScript, `X-Plasma-API: javascript`) that re-anchors the Plasma OSD to one of nine configurable positions and sets its opacity. No build system; the package lives in `kwin-script/betterosd/`. Domain terms (OSD, Anchor, Margin, Usable area, Jump) are defined in `CONTEXT.md`. README covers install/usage and must be kept in sync with behavior changes.

## Commands

```sh
./install.sh             # install/upgrade into ~/.local/share/kwin/scripts and reload it in the running KWin
./install.sh --package   # build betterosd.kwinscript (uses `nix shell nixpkgs#zip` if zip is missing)
./uninstall.sh
nix build                # package: $out/share/kwin/scripts/betterosd
nix flake check          # runs the QML tests in the sandbox
```

Tests for the pure `computePosition()` and `opacityFromPercent()` (qmltestrunner is not on PATH; find it via `ls -d /nix/store/*qtdeclarative-6*/bin`):

```sh
qmltestrunner -platform offscreen -input kwin-script/betterosd/tests   # runs every tst_*.qml
```

`main.js` guards all KWin calls with `typeof workspace !== "undefined"` so the test can import it. Keep that guard.

Live checks: trigger the OSD without keypresses via
`qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 42`
(also `showText <icon> <text>`, `brightnessChanged`, `hide`), then `spectacle -b -n -f -o /tmp/x.png`.
Settings written with `kwriteconfig6 --file kwinrc --group Script-betterosd` are picked up by the script after `qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure` without reloading it.

## How it works

- KWin hardcodes OSD placement in `Placement::placeOnScreenDisplay()`. The Plasma OSD (plasma-workspace `OsdWindow`, a `PlasmaQuick::PlasmaWindow`) is an xdg-toplevel with the plasma-surface role OnScreenDisplay, not layer-shell, so `frameGeometry` is writable from a script.
- plasmashell reuses one OSD window and toggles `visible`; on Wayland every show re-maps it, so `workspace.windowAdded` fires per show and `place()` runs each time. Config is re-read in every `place()`.
- KWin does not re-place the OSD on resize while visible; `manage()` re-places on size changes via `frameGeometryChanged`.
- The filter is `onScreenDisplay` plus resourceClass `plasmashell`/`org.kde.plasmashell`. KWin's own hint popups (`onscreennotification`) share the window type and are excluded on purpose. The desktop-change OSD is bypass-WM and cannot be moved.
- Area is `workspace.clientArea(KWin.PlacementArea, window)` (panels excluded), the same area KWin uses.

## Confirmed live (Plasma/KWin 6.7.5, Wayland)

- All of the above works: anchoring, margins, resize re-anchoring, config via the System Settings page. The user saw no visible jump.
- `spectacle -R s -b -n -o file` records the screen but cannot be stopped from the CLI (SIGINT is ignored and loses the file); the user has to stop it from the tray icon.
- Opacity is `window.opacity`, set in `manage()` on every show.
- The project was renamed from `osdposition` (config group `Script-osdposition`) to `betterosd` in 0.2.0.

## Styling beyond opacity: tried, not feasible without C++

plasmashell draws the OSD from the Plasma theme (`dialogs/background`, blur/contrast via `KWindowEffects`), so a script cannot change border, radius or colors. A JS KWin effect with a custom fragment shader (`effect.addFragmentShader`, `setUniform`, `set({type: Effect.Shader})`) was prototyped on 6.7.5 and dropped:
- Scripted-effect shaders render a frozen snapshot (`CrossFadeEffect::redirect`, taken once at `set()`), not the live window, so the OSD content (volume %) stops updating.
- Re-snapshotting (`cancel()` + `set()`) inside `windowDamaged` captures an empty texture; deferring it via a 1 ms animation and `animationEnded` (whose id arrives as 0 in JS) gave alternating frames without shader or without content, i.e. flicker.
- Live shader rendering needs `OffscreenEffect::redirect`, which is C++-only. Per-OSD blur needs a C++ effect as well.
