# 02. Leaf quick-capture and global shortcut

**Kind:** Feature

## Goal
Capture a thought in seconds without opening the app: press a shortcut anywhere, write, done.

## What was built
- A system-wide shortcut registered with Carbon `RegisterEventHotKey` (no helper program, no special permissions).
- A borderless, fully transparent panel that shows only a leaf. You write on the leaf and pin it; the thought becomes a sticky note on the board.
- Your draft is autosaved while typing, so closing the leaf never throws text away.
- `⌘↩` pins it, and a menu bar icon keeps the app reachable.

## Design choice
A leaf instead of a plain window: the quick-capture moment should feel different from managing notes.

## What was learned
A panel that is "non-activating" lets you type without stealing focus from the app you were using, which is what makes the capture feel instant.
