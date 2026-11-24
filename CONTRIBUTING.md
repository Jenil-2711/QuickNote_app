# Contributing

Thanks for your interest in Cozy Quick-Note Desk. Bug reports, ideas and pull requests are welcome.

## Reporting a bug or suggesting something
Open an issue and pick a template. Please do not paste private notes or personal information. For a bug, the most useful details are your macOS version, how you installed the app, and the exact steps to reproduce it.

## Building and testing
You need macOS 13 or later and Xcode 15 or later (or the Swift 5.9+ toolchain).

```bash
git clone https://github.com/Jenil-2711/QuickNote_app.git
cd QuickNote_app
swift build
swift test
swift run
```

To build the real app, `.dmg` and `.zip`: `./scripts/build_app.sh` (add `--install` to put it in `/Applications`).

## Where things are
- `Sources/CozyQuickNoteDesk/`: the app (see the layout in the README)
- `Tests/`: unit tests
- `scripts/`: the Python scripts that draw the artwork, and the build script
- `improvements/`: the project's log: every change, bug and lesson

## How changes are made here
This project grows in small, tested steps, and the log in `improvements/` is part of the project:
1. One change at a time, small enough to explain in a few sentences.
2. Test it in the running app, and add a unit test when it is about logic (storage, shortcuts and so on).
3. Write an entry in `improvements/`: what happened, the cause, the fix, how it was checked and what was learned. If the cause is not proven, say so.
4. Never break saved notes: keep old data readable, and add a test for it.

## Pull requests
- Keep them focused, and fill in the template.
- Do not commit personal data, private notes, build output (`.build/`, `dist/`) or large screenshots.
- Commit with your GitHub no-reply email if you want to keep your address private.

## Artwork
The room, textures, notes and leaf are drawn by the scripts in `scripts/` so they can be reproduced. If you change them, re-run the script and commit the generated images and Swift files together.

By contributing you agree that your work is released under the project's MIT license.
