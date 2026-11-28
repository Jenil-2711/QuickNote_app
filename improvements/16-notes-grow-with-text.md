# 16. Notes that grow with their text

**Kind:** Feature (and a fix for a known limit)

## What was wrong
A note has a fixed size, and its writing area is only part of that. A long thought did not fit: the text scrolled inside the small note, so most of it was hidden (a note that said "THE THOUGHT OF THE" and nothing more is what showed it up).

## The fix
A note now grows with its text. The whole note is scaled evenly (paper, stickers and writing area), so the artwork is never stretched, while the letters keep their size. A bigger note simply has room for more lines.
- Short notes stay at their usual size.
- `NoteGrowth` measures the text with the same handwriting font and finds the smallest size, in steps of 5%, at which it fits.
- Growth is limited to about twice the resting size and never taller than most of the board. Beyond that the text scrolls as before.
- A grown note moves to the front while you write in it, so it is not hidden under its neighbours.
- Nothing extra is saved: the size is worked out from the text each time, so older notes simply benefit.

## How it is checked
Unit tests cover: short and empty text stay at 1, long text grows within the limit, more text never means a smaller note, bigger letters need a bigger note, no growth allowed means no growth, and huge text stops at the limit. By hand: write a long thought in a note and in the leaf, and watch the note grow.

## What was learned
Scaling a picture evenly keeps it looking right; stretching it in one direction does not. Fit the content to the picture's shape, not the other way round.
