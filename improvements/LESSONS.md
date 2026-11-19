# Lessons learned so far

1. **SwiftUI hit testing goes to the frontmost view.** A gesture on something behind never fires (iteration 03).
2. **`.position` makes a view fill its parent.** For many overlapping items use `.offset` from a fixed origin (05).
3. **Never break saved data for a visual change.** Keep old keys and map old values (07).
4. **When a cause cannot be found by reading, change one thing at a time and add a temporary diagnostic.** Write down honestly what is still unproven (06, 11).
5. **Anything the user can break needs a message and a safe fallback**, for example a shortcut already taken by another app (08).
6. **Ship complete, verifiable changes.** Check that every expected file exists before building (09).
7. **App life cycle is a product decision.** What "quit" means must be designed (10).
8. **A global shortcut needs a running process**, so the app has to stay alive quietly, with almost no cost (10).
9. **Translucent art needs a calm reading area** so text stays legible (12).
10. **Mind privacy in public repositories**: commit with the GitHub no-reply email, and check screenshots for personal information before publishing (08).
