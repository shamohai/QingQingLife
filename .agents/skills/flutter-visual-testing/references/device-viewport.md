# Device And Viewport Rules

## Core Rule

The reference viewport and Flutter test viewport should be as close as possible.

---

# Reference Width

Common mobile design widths include:

375
390
393
412

Do not assume the screenshot width automatically equals Flutter logical width.

Determine whether the screenshot is:

* logical design size
* physical pixel export
* scaled export

---

# Recommended Test Record

Reference:

Source:
Axure export

Image size:
750 x 1624

Design scale:
2x

Logical viewport:
375 x 812

Flutter target:
375 x 812 logical pixels

---

# SafeArea

Record whether the reference includes:

* status bar
* notch
* home indicator
* Android navigation

Compare application content consistently.

Do not accidentally compare:

reference including status bar

with

Flutter screenshot excluding status bar.

---

# Responsive Verification

For important shared pages test at least:

Primary design viewport

and optionally:

one wider Android viewport

one narrower viewport

Do not sacrifice the primary approved viewport merely to optimize an unrequested device.
