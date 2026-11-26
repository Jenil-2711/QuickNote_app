# 15. Search notes

**Kind:** Feature

## Goal
With a hundred sticky notes on the board, finding one by eye is slow. Press a shortcut, type a few letters, and go straight to the note.

## How it works
- A second global shortcut (default ⌃⌥F, changeable in Settings next to the quick-capture one) opens a small search window in the upper part of the screen. It also has an entry in the menu bar.
- The results update as you type. Case, accents and extra spaces do not matter, and every word you type must appear in the note.
- Board notes come before archived ones, and newer edits come first. With nothing typed, it shows your most recent notes.
- ↑ ↓ choose, ↩ opens, Esc closes. Opening a board note shows the room and gives that note a glowing outline for a few seconds; opening an archived note shows the Archive.

## Design choices
- The search logic is a small pure function (`NoteSearch`), so it can be tested without any window.
- One shared state (`AppNavigation`) records which tab is showing and which note to highlight, so search can steer the room window.
- The search window is created when needed and released when closed, like the leaf, so it costs nothing while hidden.

## What had to change underneath
The app had one global shortcut hard-wired into its shortcut manager. A second shortcut meant the system call had to say which shortcut was pressed, so the manager now keeps a number for each shortcut. While you record a new shortcut, both are switched off, so pressing either one records it instead of firing it. Choosing the same keys for both is refused with a message.

## How it was checked
Unit tests cover case and accent handling, multi-word matching, the empty query, board-before-archive ordering, the result limit and no-match. The window and the shortcut are checked by hand: open search from another app, type, move with the arrows, press Return.

## What was learned
Adding the second of something exposes the assumptions built into the first. Generalize the plumbing once, and the third shortcut becomes easy.
