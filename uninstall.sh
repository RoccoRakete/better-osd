#!/usr/bin/env bash
# Removes the Better OSD KWin script for the current user.
set -euo pipefail

qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript betterosd >/dev/null || true
kpackagetool6 --type KWin/Script --remove betterosd || true
kwriteconfig6 --file kwinrc --group Plugins --key betterosdEnabled --delete

echo "Uninstalled."
