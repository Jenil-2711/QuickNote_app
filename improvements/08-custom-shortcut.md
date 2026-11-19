# 08. A shortcut you can change in Settings

**Kind:** Feature

## Goal
The first version had the shortcut written into the code. Users should be able to choose their own without editing anything.

## What was built
- A recorder in Settings: click it, press the new keys, and the change applies at once and is remembered.
- Rules: it must include Control, Option or Command (otherwise it would fire while typing), unless it is a function key.
- If another app already owns the combination, the old shortcut keeps working and a message explains why.
- While recording, the current shortcut is switched off so pressing it records it instead of triggering it. Esc cancels; Delete resets to the default.

## How it was checked
Unit tests cover the display format, the modifier rule and saving and loading. Manual: set a new shortcut, use it from another app, check the old one no longer works, restart, check it persists.

## A process note
The first attempt to commit this was rejected by GitHub because the commit carried a private email address. The commit was re-signed with the GitHub no-reply address and pushed.

## What was learned
Anything that can fail on the user's side (a taken shortcut) needs an explicit message and a safe fallback.
