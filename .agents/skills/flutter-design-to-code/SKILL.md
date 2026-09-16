---

name: flutter-design-to-code
description: Convert approved Axure prototypes, UI screenshots, and design images into high-fidelity, maintainable Flutter UI. Use this skill when implementing Flutter pages from screenshots, prototype exports, Axure images, segmented UI images, or when visual parity with a reference design is required.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Flutter Design To Code

## Purpose

Convert approved visual sources into maintainable Flutter code with high visual fidelity.

This skill is designed for:

* Axure RP prototype screenshots
* Axure exported page images
* Mobile app screenshots
* Segmented design images
* Approved UI mockups
* Existing app screenshots used as visual references

The goal is NOT to blindly convert pixels into hardcoded Flutter widgets.

The goal is:

> Visual source → structured design understanding → Flutter widget architecture → implementation → screenshot verification → repair loop.

---

# Ownership Boundary

This skill owns:

* extracting implementation information from approved visual sources
* screenshot and prototype analysis
* section identification
* visual hierarchy extraction
* layout measurements and proportional estimation
* Visual IR generation
* implementation blueprint generation
* mapping visual elements to Flutter widgets
* visual parity verification
* screenshot comparison
* visual repair iterations
* documenting accepted deviations

This skill does NOT own:

* business API design
* backend implementation
* database design
* payment implementation
* business state architecture decisions
* navigation architecture decisions already defined by the project
* replacing existing project architecture

For those concerns, delegate to existing project skills.

---

# Required Skill Collaboration

Before implementation, inspect and follow relevant existing skills.

Typical dependencies include:

* flutter-architecture
* flutter-navigation
* flutter-state-management
* flutter-network-api
* ecommerce-components
* ecommerce-ux
* flutter-performance
* code-quality

Do not duplicate rules already owned by those skills.

This skill focuses on the transformation:

> visual reference → high fidelity Flutter UI.

---

# Core Principle

Never directly jump from screenshot to final code unless the task is extremely small.

Use the following pipeline:

1. Inspect project conventions.
2. Inspect the visual source.
3. Create a design analysis.
4. Identify sections.
5. Create Visual IR.
6. Create an implementation blueprint.
7. Map sections to existing project components.
8. Implement incrementally.
9. Run the page.
10. Capture a screenshot.
11. Compare against the reference.
12. Repair visible mismatches.
13. Repeat until acceptable.

---

# Input Priority

Use inputs in this order:

1. Existing project implementation blueprint or page specification.
2. Existing design system and reusable components.
3. Visual IR or structured visual specification.
4. Segmented page screenshots.
5. Full-page screenshots.
6. Prototype interaction documentation.
7. User prose instructions.

A screenshot is the visual source of truth.

Existing project architecture remains the code structure source of truth.

---

# High Fidelity Mode

Enter high fidelity mode when any of the following are true:

* user asks to closely reproduce a prototype
* user provides an Axure screenshot
* user provides a reference app screenshot
* user requests pixel-level or near-pixel-level similarity
* the project is reproducing an existing approved design
* previous implementation visually differs from the prototype

When high fidelity mode is active:

* do not simplify visible structures without documenting the deviation
* do not replace visible design hierarchy with generic Material layouts
* do not use default Flutter styling blindly
* verify with screenshots
* repair significant visual mismatches before declaring completion

---

# Workflow

## Phase 0: Project Inspection

Before touching UI code:

1. Inspect project directory structure.
2. Identify feature/page organization.
3. Identify routing system.
4. Identify state management.
5. Identify existing theme system.
6. Identify reusable widgets.
7. Identify image asset conventions.
8. Identify responsive design conventions.

Prefer existing project patterns.

Do not introduce a new architecture for a single page.

---

## Phase 1: Visual Source Validation

Confirm that the visual source is usable.

For each screenshot identify:

* page name
* viewport size
* source type
* device orientation
* whether it is a full page or partial section
* whether the screenshot contains fixed navigation
* whether the screenshot contains scrolling content
* whether assets are embedded or available separately

If the screenshot is extremely long:

DO NOT treat it as one indivisible layout.

Split it conceptually into sections.

---

## Phase 2: Design Analysis Gate

Before implementation, analyze the visual source.

Record:

### Page Structure

* SafeArea usage
* top system area
* app bar
* bottom navigation
* fixed elements
* scrolling content
* overlays
* dialogs
* floating buttons

### Section Structure

For every section record:

* section id
* section type
* start position
* approximate height
* horizontal padding
* background
* separators
* visual priority

### Text

For visible text record:

* content
* hierarchy
* approximate size
* weight
* color
* line count
* overflow behavior

Do not invent text that is not visible unless required by functionality.

### Images

Classify each visual image as:

* hero
* banner
* product image
* avatar
* icon
* decorative background
* logo
* thumbnail
* illustration

Do not replace semantic icons with screenshots when an existing icon asset is available.

### Controls

Identify likely interactive elements:

* buttons
* tabs
* search fields
* product cards
* carousel indicators
* navigation items
* chips
* switches
* list items

For every control distinguish:

1. visual appearance
2. probable interaction semantics

Do not assume functionality purely from appearance.

---

# Phase 3: Section Segmentation

Divide the page into independent sections.

Example:

home_page

* app_header
* search_area
* banner_carousel
* quick_action_grid
* promotion_section
* product_section
* recommendation_feed
* bottom_navigation

Each section should be independently understandable and implementable.

Avoid one giant widget containing the entire page.

---

# Phase 4: Visual IR

Create a Visual IR before complex implementation.

Store it under a suitable project design directory when requested.

Example:

design/visual-ir/home.json

The Visual IR should describe structure, not Flutter code.

Example:

{
"pageId": "home",
"viewport": {
"width": 375,
"height": 812
},
"scroll": {
"type": "vertical"
},
"sections": [
{
"id": "header",
"type": "app_header",
"height": 88
},
{
"id": "banner",
"type": "carousel",
"marginHorizontal": 16,
"aspectRatio": 2.4
}
]
}

Do not put arbitrary Flutter widget names into Visual IR unless they are already part of the project design system.

---

# Phase 5: Implementation Blueprint

Before implementing a complex page, create an implementation blueprint.

The blueprint should include:

* page
* sections
* reusable components
* data boundaries
* interaction boundaries
* navigation hooks
* image assets
* known visual uncertainties
* accepted deviations

Example:

HomePage

├── HomeHeader
├── HomeSearchBar
├── HomeBannerCarousel
├── HomeQuickActionGrid
├── PromotionSection
├── ProductSection
└── RecommendationList

Prefer reusable components when the visual pattern is repeated.

Do not over-componentize trivial one-off layout fragments.

---

# Phase 6: Flutter Widget Mapping

Map visual structures to Flutter structures.

Prefer:

Column
Row
Expanded
Flexible
Padding
Align
Center
SizedBox
AspectRatio
LayoutBuilder
CustomScrollView
SliverAppBar
SliverList
SliverGrid
ListView.builder
GridView.builder

Use Stack only when the design actually contains overlapping layers.

Do NOT use Stack as a substitute for normal layout.

Do NOT recreate the entire screenshot with Positioned widgets.

---

# Layout Rules

## Prefer Constraint-Based Layout

Prefer:

* padding
* alignment
* flex
* aspect ratio
* responsive constraints

Avoid:

* arbitrary absolute coordinates
* excessive fixed widths
* excessive fixed heights
* hundreds of Positioned widgets

Example:

BAD:

Positioned(
left: 17,
top: 243,
width: 341,
height: 180,
)

BETTER:

Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: AspectRatio(
aspectRatio: 341 / 180,
child: ...
),
)

---

# Measurement Rules

Screenshots provide visual evidence, not guaranteed exact design metadata.

When estimating measurements:

1. normalize against screenshot width
2. infer repeated spacing scales
3. compare repeated components
4. prefer consistent spacing tokens
5. use screenshot verification after implementation

Example:

If reference width is 375px and horizontal padding appears approximately 16px:

Flutter logical implementation should normally begin near:

EdgeInsets.symmetric(horizontal: 16)

Then verify visually.

Do not create arbitrary values such as:

13.7
18.3
21.6

unless a verified project design token requires them.

---

# Typography Rules

Do not blindly use Flutter defaults.

Analyze:

* hierarchy
* font size
* font weight
* line height
* letter spacing
* truncation
* alignment

Prefer project TextTheme and typography tokens.

If the screenshot is uncertain, preserve hierarchy before chasing tiny font differences.

---

# Image and Asset Rules

Never use a screenshot crop as a permanent substitute for a semantic UI component when the component should remain dynamic.

Examples:

Do not use a screenshot of:

* a button
* a product card
* a tab
* a navigation bar

as the production UI.

Use screenshots only as references.

For bitmap assets:

* use provided assets when available
* preserve correct aspect ratio
* use appropriate BoxFit
* avoid stretching
* optimize oversized images when required

---

# Existing Component Reuse

Before creating a new component:

1. search the project for a similar component
2. compare visual structure
3. reuse if appropriate
4. extend only when necessary

Do not duplicate product cards merely because spacing differs slightly.

Prefer configurable reusable components.

---

# Interaction Preservation

Visual reproduction must not destroy functional semantics.

Examples:

A search bar should remain an input or interaction surface.

A product card should remain tappable.

Tabs should preserve active state.

Bottom navigation should integrate with the project navigation architecture.

Do not replace functional widgets with decorative Containers.

---

# Phase 7: Incremental Implementation

For complex pages implement in this order:

1. page skeleton
2. major section boundaries
3. major spacing
4. images and assets
5. typography
6. component details
7. interactions
8. loading and empty states

Do not polish tiny details before the page structure is correct.

---

# Phase 8: Visual Verification

After implementation:

1. run the application
2. navigate to the target page
3. capture a screenshot at the target viewport
4. compare with the reference

Compare section by section.

Check:

* overall page width
* header height
* major section positions
* horizontal padding
* vertical rhythm
* image aspect ratio
* card size
* typography hierarchy
* tab alignment
* icon placement
* background colors
* border radius
* bottom navigation

Do not rely only on code inspection.

---

# Parity Levels

Use approximate visual parity levels.

Level A:

Major structure differs.

Level B:

Structure matches but spacing and sizing differ significantly.

Level C:

Structure and major spacing match; visible details remain.

Level D:

High visual similarity; only minor differences remain.

Level E:

Near-reference implementation with only unavoidable platform differences.

Default target for approved prototypes:

Level D or above.

---

# Phase 9: Repair Loop

If the screenshot differs significantly:

1. identify the largest mismatch
2. identify the responsible section
3. fix one mismatch category at a time
4. rerun
5. capture another screenshot
6. compare again

Priority:

1. incorrect structure
2. incorrect section size
3. incorrect spacing
4. incorrect image sizing
5. incorrect typography hierarchy
6. incorrect colors
7. minor decorative details

Do not endlessly tweak tiny details while major layout problems remain.

---

# Deviation Policy

When the reference cannot or should not be reproduced exactly, document:

* source section
* intended reference behavior
* actual implementation
* reason
* user impact

Examples:

* platform-specific SafeArea difference
* unavailable asset
* existing project design system constraint
* dynamic content requirement
* accessibility requirement

Do not silently simplify important design elements.

---

# Flutter Quality Rules

Generated code must:

* compile
* pass formatting
* avoid obvious overflow
* avoid unnecessary rebuilds
* use const where appropriate
* use builder widgets for long lists
* respect existing state management
* respect existing navigation architecture
* avoid giant build methods when the page is complex

---

# Prohibited Patterns

Do NOT:

* recreate an entire page with a giant Stack
* use hundreds of Positioned widgets
* hardcode screenshot pixels everywhere
* use screenshots as permanent UI controls
* replace dynamic lists with static screenshot images
* create fake functionality without marking it
* overwrite project architecture for a single page
* generate a completely new design when the task is reproduction
* ignore existing reusable components
* declare visual parity without running or inspecting the page

---

# Axure Workflow

When the source is an Axure prototype:

Preferred workflow:

Axure prototype
↓
Export or capture page screenshot
↓
Record page interaction notes
↓
Segment long pages
↓
Design analysis
↓
Visual IR
↓
Implementation blueprint
↓
Flutter implementation
↓
Screenshot verification
↓
Repair loop

If available, keep interaction documentation separately.

Suggested structure:

design/
├── axure/
│   ├── home.png
│   ├── category.png
│   └── product_detail.png
│
├── visual-ir/
│   ├── home.json
│   └── category.json
│
└── interaction/
├── home.md
└── category.md

---

# Default Response Behavior

When asked:

"根据这个截图生成 Flutter 页面"

DO NOT immediately generate a huge page.

First:

1. inspect project conventions
2. inspect screenshot
3. summarize page structure
4. identify uncertain elements
5. create or describe Visual IR
6. implement using project architecture

For a very simple screen, steps 3–5 may be lightweight.

---

# Completion Criteria

Do not declare the task complete until:

* target page builds successfully
* major layout is implemented
* existing project architecture is respected
* major interactions remain semantic
* screenshot comparison was performed when high fidelity mode applies
* significant visible mismatches are repaired or documented

The final report should include:

* implemented page
* reused components
* new components
* visual parity level
* known deviations
* verification performed
