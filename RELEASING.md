# Releasing

How a new version is made, so every release follows the same checked steps.

## 1. Prepare
1. Make sure `main` is up to date and `git status` is clean.
2. Choose the new version number (for example `1.1.0`) and write it into the `VERSION` file.
3. In `CHANGELOG.md`, rename the `[Unreleased]` section to the new version with today's date, and add a fresh empty `[Unreleased]` section above it.
4. Add an entry to `improvements/` if the release brings a notable change, and tick the roadmap.

## 2. Check
```bash
swift test
./scripts/build_app.sh
```
Then check the files that will be published:
```bash
hdiutil verify dist/CozyQuickNoteDesk-<version>.dmg | tail -n 2
unzip -t dist/CozyQuickNoteDesk-<version>.zip | tail -n 1
lipo -archs "dist/Cozy Quick-Note Desk.app/Contents/MacOS/CozyQuickNoteDesk"
codesign --verify --strict --verbose=2 "dist/Cozy Quick-Note Desk.app"
```
Install the app (`./scripts/build_app.sh --install`) and try it: the shortcuts, the board, the Archive, search, Open at login.

## 3. Publish
1. Commit and push: `git add -A`, `git commit -m "Release <version>"`, `git push`.
2. On GitHub: **Releases → Draft a new release**, choose a new tag `v<version>`, title `Cozy Quick-Note Desk <version>`, paste the changelog section as the description.
3. Attach the `.dmg` and the `.zip` from `dist/`, and publish.
4. Open the release page, download the `.dmg`, and check that the app and the Applications shortcut appear.

## Rules
- Publish only the files that were built and checked on a real Mac.
- The release workflow (`.github/workflows/release.yml`) runs only by hand. Do not let it replace checked files with unchecked ones.
- Never reuse or move a published tag; make a new version instead.
