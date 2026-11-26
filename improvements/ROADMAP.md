# Roadmap

Planned work, roughly in order. This is a plan, not a promise.

## Done
- [x] Open at login switch
- [x] Customizable global shortcut
- [x] Silent background mode and a one-copy guard
- [x] App icon, `.dmg` and `.zip` build script, release workflow
- [x] Release v1.0.0
- [x] Bug report and feature request templates, contribution guide, changelog
- [x] Search notes

## Next
- [ ] Notes that grow with their text, instead of scrolling inside a small note
- [ ] More automated tests: save failures, a damaged file on disk, notes saved by older versions
- [ ] GitHub Actions: build and test on every push
- [ ] A short release routine (`RELEASING.md`): bump the version, update the changelog, tag, build
- [ ] Onboarding for first-time users
- [ ] Pinning and priority for notes
- [ ] Accessibility and keyboard navigation
- [ ] Build script tidy-ups: `diskutil` instead of `hdiutil`, remove the leftover app copy after installing
- [ ] Optional reminders and notifications
- [ ] Apple Developer ID signing and notarization, to remove the first-launch warning
