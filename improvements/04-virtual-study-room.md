# 04. The virtual study room

**Kind:** Feature

## Goal
Make the whole app feel like one place, a cozy study room, instead of an ordinary window with a picture behind it.

## What was built
- A rendered room: cream wall, wooden desk, cork board in a wooden frame, shelves, books, ivy, a lamp and fairy lights that twinkle over the real bulbs.
- A shared theme (wood, paper, walnut, sage) used by every screen: the top bar, the Archive as index cards in a wooden frame, Settings, and the leaf popup buttons.
- Sticky notes with a paper texture, placed at random on the cork board and kept inside it when the window is resized.

## Decision: draw it, do not use photos
Every image is produced by Python scripts in `scripts/`. There are no photographs, so there are no licensing worries, and the art can be changed and regenerated.

## Honest limit
The art looks like a polished illustration, not a photograph. Code cannot produce real photos; a photo could replace `room.jpg` later.

## What was learned
Generating assets from code costs more up front but makes the repository self-contained and reproducible.
