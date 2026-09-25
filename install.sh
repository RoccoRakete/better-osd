#!/usr/bin/env bash
# Installs the Better OSD KWin script for the current user and loads it
# into the running KWin. With --package, builds betterosd.kwinscript
# (for the KDE Store) instead of installing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="$SCRIPT_DIR/kwin-script/betterosd"
ID=betterosd

if [ "${1:-}" = "--package" ]; then
    OUT="$SCRIPT_DIR/$ID.kwinscript"
    rm -f "$OUT"
    ZIP=(zip)
    command -v zip >/dev/null || ZIP=(nix shell nixpkgs#zip -c zip)
    (cd "$PKG" && "${ZIP[@]}" -qr "$OUT" metadata.json contents)
    echo "Built: $OUT"
    exit 0
elif [ -n "${1:-}" ]; then
    echo "Unknown option: $1" >&2
    exit 1
fi

# 0.1.0 was called "osdposition". Remove it, or both scripts would re-place
# the OSD with different settings, and carry its settings over.
OLD_ID=osdposition
if [ -d "$HOME/.local/share/kwin/scripts/$OLD_ID" ]; then
    qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$OLD_ID" >/dev/null || true
    kpackagetool6 --type KWin/Script --remove "$OLD_ID" >/dev/null || true
    echo "Removed old version: $OLD_ID"
fi
kwriteconfig6 --file kwinrc --group Plugins --key "${OLD_ID}Enabled" --delete
migrate_key() { # old key, new key
    local value
    value="$(kreadconfig6 --file kwinrc --group "Script-$OLD_ID" --key "$1")"
    if [ -n "$value" ] && [ -z "$(kreadconfig6 --file kwinrc --group "Script-$ID" --key "$2")" ]; then
        kwriteconfig6 --file kwinrc --group "Script-$ID" --key "$2" "$value"
    fi
    kwriteconfig6 --file kwinrc --group "Script-$OLD_ID" --key "$1" --delete
}
migrate_key Enabled Reposition
migrate_key Anchor Anchor
migrate_key MarginX MarginX
migrate_key MarginY MarginY

if kpackagetool6 --type KWin/Script --install "$PKG" 2>/dev/null; then
    echo "Installed: $PKG"
else
    kpackagetool6 --type KWin/Script --upgrade "$PKG"
    echo "Upgraded: $PKG"
fi
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true

# Not calling org.kde.KWin.reconfigure: it can keep serving a stale compiled
# copy of the script. Unload + load picks up the freshly installed file.
echo "Reloading script code..."
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$ID" >/dev/null
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript \
    "$HOME/.local/share/kwin/scripts/$ID/contents/code/main.js" "$ID" >/dev/null
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null

echo "Done. Settings: System Settings > Window Management > KWin Scripts > Better OSD."
