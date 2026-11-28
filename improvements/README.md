# Improvements log

This project was not built in one go. It grows in small steps: a feature is added, tested on a real Mac, something breaks or feels wrong, the cause is tracked down, and the fix is written up here. Each entry follows the same shape: **what happened, the cause, the fix, how it was checked, and what was learned.**

Newest entry last. Plans for what comes next are in [ROADMAP.md](ROADMAP.md), and the lessons that keep repeating are collected in [LESSONS.md](LESSONS.md).

## How this project is built

- It is built by its author with AI pair-programming help (Claude). The author runs and tests every change on a real Mac and reports what is wrong; the cause is then diagnosed and fixed. Most bugs in this log were found that way, by hands-on testing rather than by guessing.
- Logic is covered by unit tests (`swift test`: storage, damaged-file recovery, failing disk, archive, shortcut rules). Behaviour that only a person can judge (clicking, dragging, the Dock, login) is checked with the manual checklists written in each entry.
- Where a cause was **not** fully proven, the entry says so instead of pretending.

## Timeline

| # | Iteration | Kind |
|---|---|---|
| 01 | [Notes engine and safe storage](01-notes-engine-and-safe-storage.md) | Foundation |
| 02 | [Leaf quick-capture and global shortcut](02-leaf-quick-capture.md) | Feature |
| 03 | [Drag, tick, delete and Esc did not work](03-board-interaction-bugs.md) | Bug fix |
| 04 | [The virtual study room](04-virtual-study-room.md) | Feature |
| 05 | [Notes could only be ticked in the order they were added](05-note-order-click-blocking.md) | Bug fix |
| 06 | [Empty Archive, and a button that did nothing](06-empty-archive.md) | Feature + bug fix |
| 07 | [Eight stationery note designs](07-eight-note-designs.md) | Feature |
| 08 | [A shortcut you can change in Settings](08-custom-shortcut.md) | Feature |
| 09 | [A real app: icon, installer, release workflow](09-real-app-and-installer.md) | Packaging |
| 10 | [Silent background mode and Open at login](10-silent-background-mode.md) | Reliability |
| 11 | [One copy at a time](11-single-instance-guard.md) | Reliability |
| 12 | [A translucent, backlit leaf](12-translucent-leaf.md) | Feature |
| 13 | [A new app icon](13-app-icon.md) | Polish |
| 14 | [Release v1.0.0](14-release-v1.md) | Packaging |
| 15 | [Search notes](15-search-notes.md) | Feature |
| 16 | [Notes that grow with their text](16-notes-grow-with-text.md) | Feature |
| 17 | [Tests, automatic checks and a release routine](17-tests-ci-and-release-routine.md) | Engineering quality |
