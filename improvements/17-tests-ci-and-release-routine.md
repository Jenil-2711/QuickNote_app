# 17. Data-safety tests, automatic checks and a release routine

**Kind:** Engineering quality

## Goal
Make sure the promises the app makes about people's notes are checked by machines, not remembered by a person, and make releases repeatable.

## What was added
- **Data-safety tests** (`DataSafetyTests`):
  - a folder that cannot be written: the user is warned, the text stays in the app, and the next change saves it
  - a damaged notes file: it is set aside (never deleted), the app starts empty and works, and the next save creates a clean file
  - a file written by version 1.0.0 still loads, and a file with an unknown design or extra fields from a future version is tolerated
  - a save leaves no temporary files behind
  - an edit is saved by itself after the delay, with no quit and no explicit save, which is the case of an app ending before the user does anything else
- **GitHub Actions CI** (`.github/workflows/ci.yml`): builds the app and runs every unit test on GitHub's Macs for each push to `main` and each pull request.
- **`RELEASING.md`**: the exact steps, checks and rules for a release.

## Why these cases
Notes are the one thing the app must never lose. Each test is a situation that has either happened (a damaged file, an old file format) or can happen to anyone (a full or read-only disk).

## Honest limits
The tests run the storage and logic code. They do not click through the interface, and a real power cut during a write cannot be simulated; the atomic write (temporary file, then swap) is what protects against that, and the test checks that no temporary files are left over.

## What was learned
Write down a promise ("your notes are safe") as a list of situations, then turn each situation into a test.
