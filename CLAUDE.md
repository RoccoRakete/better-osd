# CLAUDE.md

## What this is

A KDE Plasma 6 KWin script (plain JavaScript, `X-Plasma-API: javascript`) that re-anchors the Plasma OSD to one of nine configurable positions. No build system; the package lives in `kwin-script/osdposition/`. Domain terms (OSD, Anchor, Margin, Usable area, Jump) are defined in `CONTEXT.md`. README covers install/usage and must be kept in sync with behavior changes.

## Commands

```sh
./install.sh             # install/upgrade into ~/.local/share/kwin/scripts and reload it in the running KWin
./install.sh --package   # build osdposition.kwinscript (uses `nix shell nixpkgs#zip` if zip is missing)
./uninstall.sh
```

Tests for the pure `computePosition()` (qmltestrunner is not on PATH; find it via `ls -d /nix/store/*qtdeclarative-6*/bin`):

```sh
qmltestrunner -platform offscreen -input kwin-script/osdposition/tests/tst_position.qml
```

`main.js` guards all KWin calls with `typeof workspace !== "undefined"` so the test can import it. Keep that guard.

Live checks: trigger the OSD without keypresses via
`qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged 42`
(also `showText <icon> <text>`, `brightnessChanged`, `hide`), then `spectacle -b -n -f -o /tmp/x.png`.
Settings written with `kwriteconfig6 --file kwinrc --group Script-osdposition` are picked up by the script after `qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure` without reloading it.

## How it works

- KWin hardcodes OSD placement in `Placement::placeOnScreenDisplay()`. The Plasma OSD (plasma-workspace `OsdWindow`, a `PlasmaQuick::PlasmaWindow`) is an xdg-toplevel with the plasma-surface role OnScreenDisplay, not layer-shell, so `frameGeometry` is writable from a script.
- plasmashell reuses one OSD window and toggles `visible`; on Wayland every show re-maps it, so `workspace.windowAdded` fires per show and `place()` runs each time. Config is re-read in every `place()`.
- KWin does not re-place the OSD on resize while visible; `manage()` re-places on size changes via `frameGeometryChanged`.
- The filter is `onScreenDisplay` plus resourceClass `plasmashell`/`org.kde.plasmashell`. KWin's own hint popups (`onscreennotification`) share the window type and are excluded on purpose. The desktop-change OSD is bypass-WM and cannot be moved.
- Area is `workspace.clientArea(KWin.PlacementArea, window)` (panels excluded), the same area KWin uses.

## Confirmed live (Plasma/KWin 6.7.5, Wayland)

- All of the above works: anchoring, margins, resize re-anchoring, config via the System Settings page. The user saw no visible jump.
- `spectacle -R s -b -n -o file` records the screen but cannot be stopped from the CLI (SIGINT is ignored and loses the file); the user has to stop it from the tray icon.
