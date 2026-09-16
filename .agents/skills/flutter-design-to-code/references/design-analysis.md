# Design Analysis

Before generating Flutter code from a screenshot, perform a structured analysis.

---

# Page Analysis

Record:

* page identifier
* viewport
* background
* scroll direction
* fixed areas
* overlay areas

---

# Section Analysis

For each section:

* id
* purpose
* approximate bounds
* background
* horizontal padding
* vertical spacing
* child layout
* repeated elements

Example:

## Promotion Section

Purpose:
Display campaign entry points.

Layout:
Horizontal card list.

Padding:
Approximately 16 logical pixels.

Gap:
Approximately 12 logical pixels.

Cards:
Rounded rectangle with image above text.

Scroll:
Horizontal.

---

# Spacing Analysis

Look for repeated spacing.

Typical values may include:

4
8
12
16
20
24
32

Do not assume these values automatically.

Infer them from repeated visual relationships.

Prefer the project's spacing tokens when available.

---

# Typography Analysis

Classify text:

* display
* title
* subtitle
* body
* caption
* price
* metadata
* button label

Record:

* approximate size
* weight
* color
* alignment
* overflow behavior

---

# Layer Analysis

Determine whether the design contains:

* normal flow layout
* floating layers
* overlays
* badges
* image overlays
* sticky elements

Use Stack only for actual overlapping layers.

---

# Functional Analysis

For visible controls identify:

* visual role
* probable semantic role
* expected state

Example:

Visual:
Rounded white pill.

Semantic:
Search entry.

States:
Idle
Focused
Filled

Do not implement it as a static Container if the project requires real search interaction.

---

# Uncertainty

Assign uncertainty:

Low:
Clear visual structure.

Medium:
Visual structure clear but measurement uncertain.

High:
Behavior or component semantics cannot be determined from screenshot.

High uncertainty items should be documented before implementation.
