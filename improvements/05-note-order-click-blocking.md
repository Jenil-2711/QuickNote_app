# 05. Notes could only be ticked in the order they were added

**Kind:** Bug fix

## What happened
With four notes, note 1 could not be ticked until notes 2, 3 and 4 had been ticked first.

## Cause
Each note was placed with `.position`, which makes a view's layout frame as large as the whole board. The newest note's frame therefore sat on top of everything and swallowed clicks meant for the older notes underneath.

## Fix
Notes are now laid out from the board's top-left corner and moved with `.offset`, so each one occupies and receives clicks only in its own area. Clicking a note also lifts it above its neighbours.

## How it was checked
Add four notes, tick note 1 first, then 3, then 2, then drag and delete in a random order. All worked.

## What was learned
For many overlapping items, use `.offset` from a fixed origin. `.position` expands the layout and hides the problem until notes overlap.
