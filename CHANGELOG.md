# Changelog

All notable changes are listed here. The longer story of each change, including bugs and what was learned, is in [`improvements/`](improvements/).

## [1.0.0] - 2026-11-24

First public release.

### Added
- Global shortcut (default ⌃⌥N, changeable in Settings) that opens a translucent leaf to write on
- Cork board of sticky notes in eight stationery designs and six pastel colours
- Tick a note to move it to the Archive; restore it, delete it, or empty the Archive
- A virtual study room with fairy lights, drawn entirely by the scripts in `scripts/`
- Runs quietly in the menu bar; the Dock icon appears only while the room window is open
- Optional Open at login
- One-copy guard, so a second launch hands over to the first
- Safe storage: atomic saves, damaged files set aside, autosave
- `.dmg` and `.zip` builds for Apple Silicon and Intel, built by `scripts/build_app.sh`

### Known limits
- The app is not notarized, so macOS asks you to approve it once (System Settings → Privacy & Security → Open Anyway)
- Long text in a small note scrolls instead of growing the note
- Intel (x86_64) support is deprecated by newer macOS SDKs and may be dropped later
