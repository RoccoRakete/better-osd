/*
    Better OSD for KDE Plasma / KWin

    KWin places the Plasma OSD at a hardcoded spot (horizontally centered,
    2/3 down the screen, see Placement::placeOnScreenDisplay). This script
    re-anchors it to one of nine configurable positions every time it is
    shown or resized, and applies a configurable opacity.
*/

// Anchor index: row * 3 + column, matching the combo box order in config.ui.
function computePosition(area, size, anchor, marginX, marginY) {
    var col = anchor % 3;
    var row = Math.floor(anchor / 3);

    function axis(start, length, extent, margin, slot) {
        var pos;
        if (slot === 0) {
            pos = start + margin;
        } else if (slot === 1) {
            pos = start + (length - extent) / 2;
        } else {
            pos = start + length - extent - margin;
        }
        pos = Math.min(pos, start + length - extent);
        return Math.round(Math.max(pos, start));
    }

    return {
        x: axis(area.x, area.width, size.width, marginX, col),
        y: axis(area.y, area.height, size.height, marginY, row)
    };
}

// Below 10 % the OSD would be practically invisible.
function opacityFromPercent(percent) {
    var value = parseInt(percent, 10);
    if (isNaN(value)) {
        return 1;
    }
    return Math.min(Math.max(value, 10), 100) / 100;
}

function readBool(key, fallback) {
    var value = readConfig(key, fallback);
    return value === true || value === "true";
}

function readInt(key, fallback) {
    var value = parseInt(readConfig(key, fallback), 10);
    return isNaN(value) ? fallback : value;
}

function isPlasmaOsd(window) {
    return window.onScreenDisplay
        && (window.resourceClass === "plasmashell" || window.resourceClass === "org.kde.plasmashell");
}

function place(window) {
    if (!readBool("Reposition", true)) {
        return;
    }
    var geometry = window.frameGeometry;
    var area = workspace.clientArea(KWin.PlacementArea, window);
    var pos = computePosition(area, geometry, readInt("Anchor", 7),
                              readInt("MarginX", 0), readInt("MarginY", 100));
    if (pos.x !== geometry.x || pos.y !== geometry.y) {
        window.frameGeometry = { x: pos.x, y: pos.y, width: geometry.width, height: geometry.height };
    }
}

function manage(window) {
    if (!isPlasmaOsd(window)) {
        return;
    }
    var lastWidth = window.frameGeometry.width;
    var lastHeight = window.frameGeometry.height;
    window.frameGeometryChanged.connect(function () {
        var geometry = window.frameGeometry;
        if (geometry.width === lastWidth && geometry.height === lastHeight) {
            return;
        }
        lastWidth = geometry.width;
        lastHeight = geometry.height;
        place(window);
    });
    window.opacity = opacityFromPercent(readConfig("Opacity", 100));
    place(window);
}

if (typeof workspace !== "undefined") {
    workspace.windowList().forEach(manage);
    workspace.windowAdded.connect(manage);
}
