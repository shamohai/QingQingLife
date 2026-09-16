# Visual Verification

Visual fidelity must be verified with rendered output.

Code review alone is insufficient.

---

# Verification Workflow

1. Build the application.
2. Navigate to the target page.
3. Use the target viewport.
4. Capture a screenshot.
5. Compare against the reference.
6. Record differences.
7. Repair major differences.
8. Repeat.

---

# Comparison Order

Compare in this order:

## 1. Page Structure

* header
* scrolling region
* bottom navigation
* fixed controls

## 2. Section Boundaries

* section order
* section height
* section spacing

## 3. Horizontal Geometry

* page padding
* card width
* grid alignment

## 4. Vertical Rhythm

* section gaps
* title spacing
* card spacing

## 5. Images

* aspect ratio
* crop
* fit
* alignment

## 6. Typography

* hierarchy
* size
* weight
* alignment

## 7. Decoration

* colors
* borders
* radius
* shadows

---

# Parity Report

Every high-fidelity implementation should report:

* reference page
* target viewport
* verification method
* overall parity level
* major mismatches
* accepted deviations

---

# Important Rule

Never claim:

"pixel perfect"

unless actual comparison evidence supports that claim.

Prefer:

"high visual parity"

or

"approximate Level D parity".
