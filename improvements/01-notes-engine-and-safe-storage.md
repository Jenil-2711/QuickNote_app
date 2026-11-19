# 01. Notes engine and safe storage

**Kind:** Foundation

## Goal
A notes app people can trust with their thoughts: saving must never lose text, even if something goes wrong.

## What was built
- A native macOS app in Swift and SwiftUI that works fully offline.
- Notes kept in one JSON file in Application Support.
- Autosave: adding or deleting saves at once, edits and moves save about half a second after you stop, and everything is saved again on quit.
- Writes are atomic (a temporary file is written, then swapped in), so a crash cannot leave half a file.
- A damaged notes file is renamed `notes.damaged-<time>.json`, never deleted, and a warning is shown.
- If saving fails, the text stays in the app, a warning appears, and the next change retries.

## Why JSON and not a database
A notes app holds hundreds of notes, not millions. JSON needs no extra software and is easy to inspect. A database can be added later if it is ever needed.

## How it was checked
Unit tests cover: save and reload, a damaged file, a failing disk, quitting right after typing, archive and restore, and tilt limits.

## What was learned
Decide how the app fails (full disk, corrupted file) before adding features, and write those cases as tests first.
