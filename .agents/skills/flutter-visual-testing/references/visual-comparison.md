# Visual Comparison

## Comparison Philosophy

Visual comparison should answer:

Where is the implementation different?

How significant is the difference?

What likely caused it?

What should be changed?

---

# Comparison Layers

## Global

Check:

* viewport
* background
* SafeArea
* navigation

## Sections

Check:

* order
* size
* spacing

## Components

Check:

* cards
* banners
* buttons
* grids

## Content

Check:

* text
* images
* icons
* badges

## Decoration

Check:

* color
* radius
* borders
* shadows

---

# Overlay Thinking

When mentally or programmatically comparing two screenshots:

Ask:

If the two images were overlaid:

* which edges would diverge?
* which blocks would shift?
* where would accumulated vertical spacing appear?
* which repeated components have inconsistent dimensions?

Prioritize systematic differences.

Example:

Every section starts 4 pixels too low.

Likely cause:

Shared top padding.

Do not repair every section individually.

---

# Accumulated Error

A page can look increasingly wrong because of repeated small spacing errors.

Example:

Reference:

Section gap = 16

Implementation:

Section gap = 20

After multiple sections the lower page may shift significantly.

Identify the shared spacing cause.

---

# Comparison Output

Each issue should contain:

* section
* category
* severity
* observation
* likely cause
* repair recommendation
