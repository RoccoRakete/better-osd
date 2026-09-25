# OSD Position

A KWin script that moves Plasma's on-screen display away from its hardcoded default position to a user-chosen place on the screen.

## Language

**OSD**:
The transient popup plasmashell shows for volume, brightness, keyboard layout, microphone mute and similar changes.
_Avoid_: Notification, popup, KWin hint (KWin's own on-screen hints share the window type but are not OSDs here)

**Anchor**:
One of nine reference points on the usable area (corners, edge centers, center) that the OSD is aligned to.
_Avoid_: Position, corner, gravity

**Margin**:
The distance between the OSD and the edge of the usable area it is anchored to, applied only along an axis that is not centered.
_Avoid_: Offset, padding, spacing

**Usable area**:
The part of a screen not reserved by panels, the same area KWin uses for placing windows.
_Avoid_: Screen, work area, full screen

**Jump**:
Any rendered frame in which the OSD is shown somewhere other than its anchored target position.
_Avoid_: Flicker, glitch
