# 06. Empty Archive, and a button that did nothing

**Kind:** Feature and bug fix

## Goal
Delete every finished note in one click instead of one by one.

## What happened
The first version added a red **Empty Archive** button at the top of the Archive panel. It showed up but pressing it did nothing, while the per-note **Delete** button worked.

## Cause
**Not fully proven.** The delete dialog itself worked (the per-note button opened it), so the problem was that this particular button never received the click. Reading the code did not reveal why.

## Fix and method
The second attempt changed several things at once (the header layout, the type of dialog, a decorative border), so it could not show which one mattered, and it did not help. First the layout was simplified and the confirmation switched to a standard macOS dialog, with a temporary diagnostic message printed on each click. The button still did nothing. The third attempt changed one thing: it was moved to a footer bar at the bottom of the panel with a plain text label, like the working Delete button. That worked, and the temporary diagnostic was removed.

## How it was checked
Tick two notes, open the Archive, press Empty Archive, choose Keep it (nothing changes), press it again and confirm (the Archive empties, the board keeps its other notes). Unit tests cover the logic.

## What was learned
When the cause cannot be found by reading, change one thing at a time, add a temporary diagnostic, and record honestly that the exact cause is unconfirmed.
