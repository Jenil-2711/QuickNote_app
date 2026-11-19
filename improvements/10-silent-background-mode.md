# 10. Silent background mode and Open at login

**Kind:** Reliability

## Goal
The shortcut should work all the time, even when the app is "closed", cost almost nothing, and never show a Dock icon just because you used the leaf.

## What happened
After adding Open at login, using the shortcut made a Dock icon appear, which was not wanted.

## Design
A global shortcut can only work while some process is running, so the app stays alive quietly instead of quitting:
- It starts with no Dock icon and no window. The Dock icon appears only while the study-room window is open.
- The room window is created on demand and destroyed when closed, which releases its memory (pictures, views, animations).
- ⌘Q and Dock Quit close the room but keep the shortcut alive. **Quit Completely** in the menu bar is the real quit. A shutdown or logout is never blocked.
- An optional **Open at login** switch, with a one-time question on first launch.

## How it was checked
Manual: close the room (Dock icon disappears, shortcut still works), press the shortcut (no Dock icon), ⌘Q, restart the Mac, Quit Completely.

## Not yet measured
CPU is expected to be near zero while idle, and memory to drop when the room is closed. Real Activity Monitor numbers are still to be recorded here.

## What was learned
Where the app's life cycle is concerned, "quit" is a product decision. The behaviour users expect has to be designed, not left to defaults.
