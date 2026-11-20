# 13. A new app icon

**Kind:** Polish

## Goal
Replace the first app icon (a leaf pinned to cork, drawn by `scripts/generate_icon.py`) with a calmer design that matches the app's cream and beige palette and says "notes" at a glance: a sticky note, a green leaf and a fountain pen.

## How it was made
- The design was generated with an AI image tool (Gemini) from the author's idea.
- `scripts/prepare_icon.py` turns that picture into the app icon: it finds the rounded square, removes the plain background, shadow and corner watermark, places it on Apple's icon grid (an 824 px body in a 1024 px canvas) and adds a soft shadow.
- `scripts/build_app.sh` converts `assets/AppIcon-1024.png` into the `.icns` file for every size macOS needs, so the Dock, Launchpad, Finder and the `.dmg` all use it.
- The same script also makes `assets/social-preview.png`, the 1280×640 card shown when the repository link is shared.

## Keeping the README honest
The README said all artwork was rendered by code. That is no longer fully true, so the README was updated: the icon is the one exception, it was AI-generated, and the old code-drawn icon is kept as an alternative.

## How it was checked
Looked at the cut-out on light and dark backgrounds and at small sizes (the leaf and pen stay readable at 64 px; at 16 px only the shape remains, which is normal). On the Mac: rebuild and reinstall, then check the Dock, Launchpad, Spotlight and Finder.

## What was learned
When an asset changes how it was made, update the documentation that describes it.
