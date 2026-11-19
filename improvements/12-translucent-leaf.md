# 12. A translucent, backlit leaf

**Kind:** Feature

## Goal
Replace the maple leaf with a more natural green leaf and let what is behind it show through, like light passing through a real leaf.

## What changed
- New artwork, still drawn by code (`scripts/generate_leaf.py`): an ovate leaf with a serrated edge, a bent midrib, curved side veins and a fine cell network made with cellular (Worley) noise.
- The leaf is **semi-transparent**: the window or page you were just using shows through the leaf, while the veins stay solid. The drop shadow was removed, because a shadow would show through a translucent leaf and make it muddy.
- A pale, calmer, more solid patch in the middle is the writing area, so text stays readable over busy windows. Its position is exported to Swift automatically (`LeafLayout.swift`).
- The app icon now uses the new leaf.

## How it is to be checked
Open the leaf over a dark desktop, a white page and a busy browser tab; the text must stay readable and the content behind should be visible through the leaf. Pin a thought and confirm it still lands on the board.

## What was learned
Translucency is a trade-off with legibility. Keep the reading area calmer and more opaque than the decoration around it.
