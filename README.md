# OSD Position

A KWin script for KDE Plasma 6 that moves the Plasma on-screen display (volume, brightness, keyboard layout, microphone mute, ...) to a corner, an edge or the center of the screen.

Plasma has no setting for this: KWin always places the OSD horizontally centered, two thirds down the screen.

## Features

- Nine positions: top/center/bottom combined with left/center/right
- Horizontal and vertical margin in pixels, measured from the screen edge without panels, so the OSD never covers a panel
- Keeps the OSD anchored when it changes size while visible (e.g. a volume OSD followed by a keyboard layout OSD)
- Stays on the screen KWin picked for the OSD
- Only affects the Plasma OSD, not KWin's own on-screen hints

Tested on Plasma 6.7 (Wayland).

## Install

From a checkout:

```sh
./install.sh
```

Or install `osdposition.kwinscript` via System Settings > Window Management > KWin Scripts > Install from File.

## Configure

System Settings > Window Management > KWin Scripts > OSD Position > configure button. Changes take effect the next time the OSD appears.

Remove any window rule you may have created for on-screen display windows; it would conflict with this script.

## Uninstall

```sh
./uninstall.sh
```

## Development

```sh
./install.sh --package   # build osdposition.kwinscript for the KDE Store
qmltestrunner -input kwin-script/osdposition/tests/tst_position.qml
```

## License

GPL-2.0-or-later
