# 11. One copy at a time

**Kind:** Reliability

## What happened
Once, two leaf icons appeared in the menu bar. It was not reproduced afterwards.

## Likely causes (not proven)
1. Two copies of the app running at once, for example a development run from the terminal beside the installed app, or an old copy still alive while a new one was installed. The installer's polite "quit" no longer worked after iteration 10, because quitting now only closes the room.
2. A leftover "ghost" icon after a force-quit, which disappears when the mouse moves over it.
3. Two login entries pointing at different copies.

## Fix
- The first copy takes a file lock that macOS releases automatically if the app quits or crashes. A second copy hands over to the first (which shows its window) and exits before it can create an icon.
- The installer now stops every old copy before replacing the app.

## How it was checked
Planned manual check: with the app running, start a second copy; it should print a message and exit, leaving one icon.

## What was learned
A rare, unreproduced sighting still deserves a defensive fix, as long as the log says the cause is unconfirmed.
