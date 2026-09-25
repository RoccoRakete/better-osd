#!/usr/bin/env bash
# Removes the OSD Position KWin script for the current user.
set -euo pipefail

qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript osdposition >/dev/null || true
kpackagetool6 --type KWin/Script --remove osdposition || true
kwriteconfig6 --file kwinrc --group Plugins --key osdpositionEnabled --delete

echo "Uninstalled."
