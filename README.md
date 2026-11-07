# 🍃 Cozy Quick-Note Desk

A native macOS app that turns your thoughts into sticky notes pinned on a cork board, in a warm, softly lit **virtual study room**. Wooden desk, ivy, shelves of books, a glowing lamp and twinkling fairy lights. Every screen belongs to the same room.

> Press a shortcut from anywhere → a transparent **maple leaf** floats up → write your thought → it's pinned on your board. Tick the circle when it's done and it fades into the Archive.

**Capture instantly · save automatically · organize naturally · complete peacefully.**

<!-- Add screenshots here once you have them:
![Study room](docs/board.png)
![Leaf quick capture](docs/leaf.png)
![Archive](docs/archive.png)
-->

## Features
- 🍂 **Leaf quick-capture**: global shortcut **⌃⌥N** (built in) opens a transparent leaf to type on. `⌘↩` pins it, `Esc` leaves the text box, `Esc` again closes. Your draft is autosaved.
- 📌 **Cork board of sticky notes**: pastel paper with push-pins, mostly square pads plus the occasional heart, apple, strawberry, bear, star or tree. Placed naturally at random, tilted ±4°, draggable. Positions and tilt are remembered.
- 🌿 **One cohesive room**: the board, the Archive (index cards in a wooden frame), Settings and the leaf popup all share the same wood, paper and warm-light look.
- ✨ **Fairy lights** gently twinkle over the real bulbs in the room.
- ✅ **Peaceful completion**: circular checkbox, green tick, gentle fade, then into the Archive. Restore or delete permanently from there.
- 💾 **Safe storage**: one JSON file, atomic writes, damaged files set aside (never deleted).
- 🔒 **Private**: no accounts, no cloud, no network.
- 🧭 Menu bar icon keeps the shortcut alive after you close the main window.

## Requirements
macOS 13+, Xcode 15+ (or the Swift 5.9+ toolchain).

## Run
```bash
git clone https://github.com/Jenil-2711/CozyQuickNoteDesk.git
cd CozyQuickNoteDesk
swift run
```
Open the folder in **VS Code** with the Swift extension (`swiftlang.swift-vscode`) or open `Package.swift` in Xcode.

```bash
swift test                 # unit tests (storage, damaged file, failing disk, quit-while-typing…)
./scripts/build_app.sh     # builds dist/Cozy Quick-Note Desk.app
```

## Project layout
```
Package.swift
Sources/CozyQuickNoteDesk/
  App/            entry point, app delegate, constants (hard-coded shortcut)
  Models/         Note, NoteColor, NoteShape, NotePlacement
  Storage/        JSONNoteStore (atomic, damage-safe)
  Managers/       NoteManager (the app's "brain")
  QuickCapture/   global hotkey, transparent leaf panel and view, draft autosave
  Theme/          palette, fonts, wood and paper surfaces, push-pin, buttons
  Views/
    Room/         room background, twinkling lights, board layout constants
    Board/        cork board screen, sticky notes and their shapes
    Archive/      index-card archive
    Settings/     settings sheet
    Shared/       resource loading
  Resources/      room.jpg, wood.jpg, paper.jpg, leaf.png
Tests/            XCTest suites
scripts/          generate_assets.py, studio_lib.py, generate_leaf.py, build_app.sh
docs/             DESIGN.md
```

## About the artwork
There are **no photographs** in this repository. The room, wood, cork, paper and leaf are all rendered by the Python scripts in `scripts/` (procedural wood grain, cork, plaster, shaded leaves, books, lamp and light glow), so there are no licensing worries and everything is reproducible:

```bash
pip install pillow numpy
python3 scripts/generate_assets.py   # room.jpg, wood.jpg, paper.jpg + layout constants
python3 scripts/generate_leaf.py     # leaf.png
```
Want a different mood? Edit the colours and object positions in `scripts/generate_assets.py` and re-run it. The cork-board position and light positions are exported to Swift automatically.

## Customising
- **Shortcut:** edit `hotKeyCode` / `hotKeyModifiers` in `AppConstants.swift`.
- **Palette and fonts:** `Theme/Theme.swift`.
- **Room:** `scripts/generate_assets.py`.

## Roadmap
- [x] Foundation, note engine, autosave
- [x] Quick capture (leaf), menu bar, shortcut
- [x] Virtual study room, cork board, shaped notes, dragging
- [x] Completion, archive, restore
- [ ] Final polish, app icon, release build

## License
MIT
