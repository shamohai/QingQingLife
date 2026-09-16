# Screenshot Capture

## Purpose

Define stable screenshot capture practices for Flutter visual testing.

---

# 1. Viewport Consistency

Always record:

* platform
* device or emulator
* logical width
* logical height
* orientation

Example:

Android
375 x 812
Portrait

Do not compare screenshots from significantly different viewports without normalization.

---

# 2. Stable State

Before capture ensure:

* page is fully loaded
* images are loaded
* animations are settled
* scrolling position is correct
* keyboard is hidden unless intentionally visible
* dialogs are either intentionally visible or dismissed

---

# 3. Capture States

For scrollable pages define the capture state.

Examples:

home-top
home-middle
home-products

Recommended:

{page-id}-{state}-{viewport}.png

Example:

home-top-375x812.png

---

# 4. Long Pages

Do not require one screenshot containing an entire extremely long page.

Capture:

* top
* important middle sections
* lower sections

Compare sections independently.

---

# 5. Dynamic Content

Avoid unstable content such as:

* random recommendations
* rotating advertisements
* live timestamps
* changing inventory

Use stable test fixtures when possible.

---

# 6. Screenshot History

Preserve important iterations.

Example:

visual-tests/
└── home/
├── reference.png
├── implementation-v1.png
├── implementation-v2.png
└── implementation-final.png

Do not overwrite the original reference.
