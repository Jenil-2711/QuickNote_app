# Roadmap

Planned work, roughly in order. This is a plan, not a promise.

## Done
- [x] Open at login switch
- [x] Customizable global shortcut
- [x] Silent background mode, single-instance guard
- [x] App icon, `.dmg` and `.zip` build script, release workflow

## Next: finish the product
- [ ] Publish release v1.0.0 and check the download from the Releases page
- [ ] README screenshots
- [ ] Apple Developer ID signing and notarization, to remove the first-launch warning

## Reliability
- [ ] Record real idle CPU and memory numbers
- [ ] Test Open at login and the shortcut after a restart, and across app updates
- [ ] More tests: unexpected termination during autosave, storage permission and disk-write failures, notes surviving updates

## Features
- [ ] **Search notes**: press a shortcut, type a keyword, jump to the note (useful once there are many notes)
- [ ] Pinning and priority
- [ ] Optional reminders and notifications

## Polish and project quality
- [x] Bug report and feature request templates, pull request template
- [x] Contribution guidelines and a changelog
- [ ] Accessibility and keyboard navigation, onboarding for first-time users
- [ ] Notes that grow with their text, instead of scrolling inside a small note
- [ ] Retake the older Archive screenshots
- [ ] GitHub Actions build and test on every push
