# 07. Eight stationery note designs

**Kind:** Feature

## Goal
Replace the first set of note shapes with eight cozy stationery designs (spiral notebook, taped page, ring binder, perforated checklist with a bow, torn paper and more) with little bear, gingerbread, cookie and cupcake stickers. Each new note gets one at random.

## How it works
Each design is two images: a near-white **paper layer** that is tinted with the chosen pastel colour, and an untinted **decoration layer** (tape, bows, stickers). The colour picker therefore keeps working on every design.

## A risk that was handled
Notes saved by earlier versions used the old shape names. The data key was kept and old names are mapped to a design, so existing files still load instead of being treated as damaged. A unit test covers this.

## What was learned
Changing what the app saves is a data-format decision. Never break people's saved notes for a visual change.
