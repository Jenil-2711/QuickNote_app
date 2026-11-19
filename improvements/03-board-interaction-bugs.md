# 03. Drag, tick, delete and Esc did not work

**Kind:** Bug fix

## What happened
Testing the first board showed three problems:
1. Once the cursor was placed in a note or the leaf, there was no way to get out of it.
2. The tick circle and the trash button did nothing.
3. Notes could not be dragged.

## Cause
- The drag gesture was attached to a view *behind* the coloured paper. In SwiftUI, a click goes to the frontmost view, so the gesture behind never received it.
- The tick circle and trash icon only reacted on their thin outlines (their transparent middle was not clickable).
- There was no Esc handling at all.

## Fix
- The gesture now sits on the paper itself; the text box handles its own clicks.
- Every button got a full clickable area.
- Esc leaves the text box; a second Esc closes the leaf. Clicking empty space also drops the cursor.

## How it was checked
Manual checklist: drag a note by its margin, tick, delete, click into a note then press Esc, then the same on the leaf. All passed.

## What was learned
In SwiftUI the frontmost view wins hit testing. A gesture on something behind never fires, and "clickable" areas are only as big as what is drawn unless a content shape is set.
