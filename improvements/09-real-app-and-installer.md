# 09. A real app: icon, installer, release workflow

**Kind:** Packaging

## Goal
Run the app without a terminal, and let other people download it.

## What was built
- `scripts/build_app.sh` builds a universal app (Apple Silicon and Intel), adds an icon, signs it ad hoc, and produces a `.dmg` and a `.zip`. With `--install` it copies the app into `/Applications`.
- An app icon drawn by `scripts/generate_icon.py`.
- A GitHub Actions workflow that builds the same files on GitHub's Macs when a version tag is pushed.

## What went wrong along the way
The first run of the new script failed with "VERSION: No such file". Updates had been applied in pieces and one small file never reached the project folder. A package with just the missing files fixed it.

## Honest limit
The app is not notarized (that needs a paid Apple developer account), so other people see a macOS warning on first launch. The README explains the one-time workaround. Notarization is on the roadmap.

## What was learned
Deliver whole, verifiable changes and check that every expected file exists before running a build.
