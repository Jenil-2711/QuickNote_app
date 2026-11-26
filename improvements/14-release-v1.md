# 14. Release v1.0.0

**Kind:** Packaging

## Goal
Turn the project into something anyone can download and run, not just something that builds on the author's Mac.

## What was done
- `scripts/build_app.sh` produced `CozyQuickNoteDesk-1.0.0.dmg` (7.0 MB) and `CozyQuickNoteDesk-1.0.0.zip` (6.7 MB).
- Both files were checked before publishing: the disk image checksum is valid, the zip has no errors, the app inside the disk image passes a strict signature check, and the program contains both Intel and Apple Silicon code.
- The installed app is 8.6 MB. The notes file is 4 KB. In Activity Monitor the app showed an Energy Impact of 0.0 while idle, with a 12-hour power score of 0.50 next to 356.83 for the browser (a relative score).
- The release was published on GitHub with both files attached.

## Problems found on the way
1. **First-launch instructions were out of date.** On macOS 15 and later, right-click then Open no longer lets an unnotarized app through. The README now explains System Settings → Privacy & Security → Open Anyway first, and keeps the older method for macOS 13 and 14.
2. **An untested automation could have replaced the tested files.** The release workflow was set to run on every version tag, so publishing would have started a build on GitHub's computers that could overwrite the hand-tested files. It now runs only when started by hand, until its own build has been verified.
3. **Build warnings, noted for later:** Intel (x86_64) support is deprecated by the newest macOS SDK; the resource bundle cannot be signed separately (the app's own signature is valid); and `hdiutil` is deprecated in favour of `diskutil`.

## Honest limits
The app is not notarized, so every new user sees a macOS warning once. Notarization needs a paid Apple developer account and stays on the roadmap.

## What was learned
Test the exact files you will publish, and do not let automation that has never run publish for you.
