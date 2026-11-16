> This repository has moved to https://git.mscloud.uk/martin/better-osd and is archived. Development and CI happen there.

# Better OSD

A KWin script for KDE Plasma 6 that moves the Plasma on-screen display (volume, brightness, keyboard layout, microphone mute, ...) to a corner, an edge or the center of the screen, and can make it translucent.

Plasma has no setting for this: KWin always places the OSD horizontally centered, two thirds down the screen.

## Features

- Nine positions: top/center/bottom combined with left/center/right
- Horizontal and vertical margin in pixels, measured from the screen edge without panels, so the OSD never covers a panel
- Keeps the OSD anchored when it changes size while visible (e.g. a volume OSD followed by a keyboard layout OSD)
- Opacity from 10 to 100 %, relative to the Plasma style (100 % leaves the OSD as the style draws it; it cannot be made more opaque than that)
- Stays on the screen KWin picked for the OSD
- Only affects the Plasma OSD, not KWin's own on-screen hints

Tested on Plasma 6.7 (Wayland).

## Install

From a checkout:

```sh
./install.sh
```

Or install `betterosd.kwinscript` via System Settings > Window Management > KWin Scripts > Install from File.

### NixOS (flake)

```nix
# flake.nix
inputs.better-osd = {
  url = "github:RoccoRakete/better-osd";
  inputs.nixpkgs.follows = "nixpkgs";
};

# NixOS configuration
environment.systemPackages = [
  inputs.better-osd.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

The script is enabled by default; configure it in System Settings as below. A copy installed with `./install.sh` in `~/.local/share/kwin/scripts` takes precedence over the system one, so remove it with `./uninstall.sh` after switching.

Upgrading from 0.1.0 ("OSD Position"): `./install.sh` removes the old script and carries over its settings. If you installed from a file, remove "OSD Position" in KWin Scripts yourself and set your position and margins again.

## Configure

System Settings > Window Management > KWin Scripts > Better OSD > configure button. Changes take effect the next time the OSD appears.

Remove any window rule you may have created for on-screen display windows; it would conflict with this script.

## Uninstall

```sh
./uninstall.sh
```

## Development

```sh
./install.sh --package   # build betterosd.kwinscript for the KDE Store
qmltestrunner -input kwin-script/betterosd/tests   # runs every tst_*.qml
```

## License

GPL-2.0-or-later
