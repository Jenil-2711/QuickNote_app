# Design notes

**Philosophy:** capture instantly, save automatically, organize naturally, complete peacefully.

**Visual identity:** a warm, cream-and-beige study room with natural wood, living plants, books and
fairy lights. Every component (top bar, board, archive, settings, leaf popup, confirmation card)
uses the same wood and paper materials from `Theme/`, so nothing looks like a stock Mac window
dropped in front of a picture.

| Decision | Choice | Why |
|---|---|---|
| Platform | Native macOS, Swift + SwiftUI | Light, fast, offline, can use global shortcuts and the menu bar |
| Storage | One JSON file in Application Support | A notes app holds hundreds of notes, not millions; atomic writes make crashes safe |
| Global shortcut | Hard-coded in `AppConstants.swift`, registered with Carbon `RegisterEventHotKey` | No helper app, no permissions, instant |
| Quick capture | Transparent maple leaf panel | Playful, distinct from the board's sticky notes |
| Artwork | Rendered by Python scripts, committed as JPG | No licensing issues, reproducible, tweakable |
| Note placement | Random spot on the cork board, far from other notes; stored as fractions of the board | Looks naturally filled and survives window resizing |
| Notes | Mostly square pads with push-pins, occasional shapes, tilted -4°…+4° | Feels like a real pinboard, text stays readable |
| Completion | Tick, fade, move to Archive | Completing never deletes |
| Privacy | No accounts, no cloud, no network | Everything stays on the Mac |

## Data safety
- Add / delete / complete / restore: saved immediately. Edits and moves: saved ~0.5 s after you stop. Saved again on quit.
- Writes are atomic (temp file, then swap).
- A damaged file is renamed `notes.damaged-<timestamp>.json`, never deleted, and a warning tag is shown.
- If saving fails the text stays in the app, a warning appears, and the next change retries.

## Keyboard
- `⌃⌥N` anywhere: open the leaf. `⌘↩` pins. `Esc` leaves the text box; a second `Esc` closes the leaf.
- `Esc` inside a board note stops the blinking cursor; clicking the empty wall or board does too.

## Deliberately not in v1.0
Cloud sync, iOS/iPadOS, accounts, sharing, collaboration, reminders, attachments, tags, AI, multiple rooms, statistics.
