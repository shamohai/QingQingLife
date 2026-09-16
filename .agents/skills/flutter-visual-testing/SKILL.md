---

name: flutter-visual-testing
description: Verify Flutter UI visual fidelity by capturing rendered pages, comparing them against approved screenshots or Axure prototype references, analyzing visible differences, and guiding controlled repair iterations. Use for screenshot comparison, visual regression checks, high-fidelity UI verification, and prototype-to-Flutter parity testing.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Flutter Visual Testing

## Purpose

This skill verifies whether a rendered Flutter page visually matches an approved reference.

Primary workflow:

Reference Screenshot
↓
Flutter Implementation
↓
Run Application
↓
Navigate To Target Page
↓
Capture Screenshot
↓
Compare
↓
Difference Analysis
↓
Repair
↓
Capture Again
↓
Final Parity Report

This skill does not primarily generate UI.

It verifies UI.

For screenshot-to-code generation, use:

flutter-design-to-code

---

# Ownership

This skill owns:

* visual test planning
* target viewport definition
* screenshot capture strategy
* screenshot naming
* reference versus implementation comparison
* difference classification
* visual parity evaluation
* repair prioritization
* visual repair logs
* regression verification

This skill does NOT own:

* business API testing
* backend testing
* payment testing
* database testing
* full business workflow testing
* replacing Flutter unit or widget tests

---

# Required Collaboration

When visual testing a page generated from a prototype, collaborate with:

* flutter-design-to-code
* flutter-architecture
* ecommerce-components
* ecommerce-ux
* flutter-performance
* code-quality

Do not modify project architecture merely to improve screenshot similarity.

---

# Core Principle

Never evaluate visual fidelity by reading source code alone.

Visual fidelity requires rendered output.

The correct sequence is:

Implement
→ Run
→ Capture
→ Compare
→ Analyze
→ Repair
→ Verify

---

# Visual Test Levels

## Level 1: Structural Verification

Verify:

* page opens
* major sections exist
* scrolling works
* fixed areas exist

No detailed pixel comparison required.

---

## Level 2: Layout Verification

Verify:

* section order
* major widths
* major heights
* horizontal padding
* vertical spacing

---

## Level 3: Visual Verification

Verify:

* typography hierarchy
* images
* colors
* radius
* shadows
* icon alignment

---

## Level 4: High Fidelity Verification

Verify:

* overall geometry
* section geometry
* image crop
* spacing rhythm
* typography hierarchy
* major visual details

This is the default level when reproducing an approved Axure prototype.

---

## Level 5: Near-Reference Verification

Use only when:

* viewport is controlled
* assets are identical
* fonts are controlled
* platform differences are minimized

Do not claim pixel-perfect parity unless actual evidence supports it.

---

# Phase 0: Prepare Test Plan

Before testing, define:

* page id
* reference screenshot
* reference viewport
* Flutter target platform
* test viewport
* navigation path
* dynamic data assumptions
* authentication assumptions
* visual test level

Example:

Page:
home

Reference:
design/axure/home.png

Reference Viewport:
375 x 812

Target:
Android Emulator

Visual Level:
Level 4

---

# Phase 1: Environment Stability

Before capturing screenshots ensure:

* correct application version
* stable viewport
* stable device orientation
* stable font scale
* stable display scale when possible
* stable application state

Avoid comparing screenshots when:

* random content is changing
* network banners rotate unpredictably
* animation is mid-transition
* timestamps differ visibly
* remote images are still loading

---

# Dynamic Content Policy

Prototype screenshots often contain static content.

Production applications often contain dynamic content.

For meaningful comparison:

Prefer one of:

1. local mock data
2. fixed test API data
3. stable development environment
4. screenshot mode
5. fixture data

Document which strategy is used.

Do not modify production behavior merely for screenshot testing.

---

# Phase 2: Screenshot Capture

Capture screenshots using the same viewport as the reference whenever possible.

Record:

* device
* resolution
* logical viewport
* orientation
* capture method
* application state

Recommended naming:

{page-id}-{platform}-{width}x{height}.png

Example:

home-android-375x812.png

For iterations:

home-android-375x812-v1.png
home-android-375x812-v2.png
home-android-375x812-v3.png

Never overwrite the original reference.

---

# Phase 3: Comparison

Compare reference and implementation in layers.

## Layer 1: Global Structure

Check:

* SafeArea
* app bar
* bottom navigation
* page background
* scroll region

---

## Layer 2: Section Geometry

Check:

* section positions
* section heights
* section spacing
* section padding

---

## Layer 3: Component Geometry

Check:

* cards
* banners
* grids
* tabs
* buttons

---

## Layer 4: Content Geometry

Check:

* image aspect ratios
* text wrapping
* icon position
* price alignment
* badges

---

## Layer 5: Decoration

Check:

* color
* border
* radius
* shadow
* gradient

---

# Difference Categories

Classify every significant difference.

## STRUCTURE

Example:

Reference contains bottom navigation.
Implementation does not.

---

## SIZE

Example:

Banner is visibly taller.

---

## SPACING

Example:

Product cards have excessive horizontal gap.

---

## ALIGNMENT

Example:

Title is vertically misaligned.

---

## TYPOGRAPHY

Example:

Price hierarchy is too weak.

---

## IMAGE

Example:

Image crop differs significantly.

---

## COLOR

Example:

Background is too dark.

---

## DECORATION

Example:

Card radius is incorrect.

---

## PLATFORM

Example:

SafeArea differs between Android and the prototype reference.

---

# Severity

Assign severity:

CRITICAL

Page structure differs.

HIGH

Major section geometry differs.

MEDIUM

Visible component geometry differs.

LOW

Minor typography or decoration difference.

COSMETIC

Tiny detail with minimal user impact.

---

# Phase 4: Difference Analysis

Do not produce vague feedback such as:

"Looks slightly different."

Instead produce:

Section:
banner

Category:
SIZE

Severity:
HIGH

Reference:
Banner occupies approximately 42% of the visible content width-to-height ratio.

Implementation:
Banner is approximately 15% taller.

Likely Cause:
Fixed height is inconsistent with reference aspect ratio.

Suggested Repair:
Use AspectRatio or update constrained height.

---

# Phase 5: Repair Priority

Repair in this order:

1. STRUCTURE
2. SIZE
3. SPACING
4. ALIGNMENT
5. IMAGE
6. TYPOGRAPHY
7. COLOR
8. DECORATION
9. COSMETIC

Do not optimize shadows before fixing page geometry.

---

# Controlled Repair Loop

Each iteration should:

1. select the highest-priority mismatch
2. identify responsible widget
3. make minimal targeted changes
4. rebuild or hot restart when required
5. capture screenshot
6. compare again
7. record result

Avoid changing unrelated sections.

---

# Maximum Repair Discipline

If three iterations fail to improve a section:

STOP.

Re-check:

* reference interpretation
* viewport
* source assets
* Flutter layout assumptions
* font differences

Do not endlessly tweak numbers.

---

# Platform Differences

Prototype references may visually resemble:

* iOS
* Android
* generic mobile design

Flutter output may differ due to:

* SafeArea
* status bar
* font rendering
* system navigation
* Material defaults
* Cupertino defaults

Document unavoidable differences.

Do not hide significant mistakes behind:

"platform difference"

unless the difference is genuinely platform-specific.

---

# Phase 6: Regression Verification

After repairing one page:

Verify that shared components have not broken other pages.

Especially check:

* AppHeader
* ProductCard
* PriceWidget
* BottomNavigation
* shared spacing tokens
* shared image widgets

If a shared component changed:

Run visual verification on at least one additional representative page.

---

# Visual Parity Levels

## A

Major visual mismatch.

Not acceptable.

## B

Structure recognizable but major geometry differs.

Needs repair.

## C

Overall layout matches but visible differences remain.

Acceptable for early development.

## D

High visual parity.

Default target for approved prototypes.

## E

Near-reference output under controlled conditions.

Use only when evidence supports it.

---

# Completion Criteria

A visual test is complete when:

* target page runs successfully
* correct viewport was used
* reference and implementation were compared
* significant differences were classified
* high-priority differences were repaired
* remaining differences were documented
* parity level was assigned honestly

---

# Final Report

Every completed high-fidelity test should include:

* page
* reference source
* viewport
* platform
* test level
* parity level
* repaired issues
* remaining issues
* accepted deviations
* regression checks

---

# Prohibited Behavior

Do NOT:

* declare visual parity without rendered output
* compare only source code
* ignore viewport differences
* compare while content is still loading
* endlessly tweak random pixel values
* repair cosmetic issues before structure
* overwrite reference screenshots
* call a result pixel-perfect without evidence
