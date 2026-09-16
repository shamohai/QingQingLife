# Axure Screenshot Workflow

## Purpose

Define the workflow for converting Axure RP prototypes into Flutter implementation references.

---

# 1. Export Strategy

Prefer one screenshot per application page.

Example:

design/axure/

* home.png
* category.png
* product_detail.png
* cart.png
* profile.png

For extremely long pages, also provide section screenshots.

Example:

home/

* 01_header.png
* 02_banner.png
* 03_quick_actions.png
* 04_promotion.png
* 05_products.png

Keep the full page screenshot as the visual context source.

Use section screenshots for detailed analysis.

---

# 2. Record Viewport

For every exported page record:

* design width
* design height
* device model if known
* orientation

Example:

home:
width: 375
height: 812
orientation: portrait

Do not assume all screenshots use the same viewport.

---

# 3. Interaction Documentation

Screenshots describe appearance.

They do not reliably describe behavior.

Create interaction notes.

Example:

# Home Page Interaction

## Search Bar

Tap opens search page.

## Banner

Supports automatic carousel.

Tap navigates to promotion detail.

## Category Item

Tap opens category channel.

## Product Card

Tap opens product detail.

---

# 4. Long Page Handling

Never treat an extremely long page as one Flutter widget tree.

Segment into:

* header
* hero
* navigation
* grids
* promotion blocks
* product lists
* recommendation feed
* footer

Each section should have an independent visual contract.

---

# 5. Asset Handling

If Axure exports contain embedded bitmap assets:

Do not automatically use the entire screenshot as an asset.

Classify assets:

* reusable bitmap
* product image
* banner
* icon
* decorative image
* UI screenshot artifact

Only real assets should enter the Flutter asset pipeline.

---

# 6. Screenshot Naming

Use stable names.

Recommended:

{page-id}.png

For sections:

{page-id}-{order}-{section-id}.png

Example:

home-01-header.png
home-02-banner.png
home-03-categories.png

Avoid names such as:

image1.png
final.png
new-final2.png

---

# 7. Source of Truth

When sources conflict:

1. approved latest prototype
2. approved screenshot
3. interaction documentation
4. implementation blueprint
5. prose description

If uncertainty remains, record it instead of inventing complex behavior.
