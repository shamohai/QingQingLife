# Flutter Generation Rules

## 1. Respect Existing Architecture

Before generating code inspect:

* feature directory conventions
* state management
* routing
* theme
* reusable components

Do not create parallel architecture.

---

# 2. Widget Mapping

Visual Section:

Header

Preferred Flutter:

AppBar
SliverAppBar
Custom header widget

Visual Section:

Vertical feed

Preferred Flutter:

ListView.builder
SliverList

Visual Section:

Grid

Preferred Flutter:

GridView.builder
SliverGrid

Visual Section:

Carousel

Preferred Flutter:

Existing carousel component or approved package.

Visual Section:

Floating badge

Preferred Flutter:

Stack with limited Positioned usage.

---

# 3. Component Extraction

Extract a component when:

* repeated
* independently interactive
* reused across pages
* visually complex
* independently testable

Do not extract:

A one-line SizedBox.

A trivial one-off Padding wrapper.

---

# 4. Avoid Screenshot Coding

Never translate every visible coordinate directly into Positioned.

The screenshot is a reference.

Flutter should use constraints.

---

# 5. Page Structure

Prefer:

Scaffold
SafeArea
CustomScrollView
Slivers

when appropriate.

Do not force every page into:

SingleChildScrollView
Column
hundreds of children

for large e-commerce pages.

---

# 6. Dynamic Data

Visual prototypes often contain static examples.

Implement dynamic boundaries where required.

Example:

Do not create:

ProductCard(
title: "Example Product",
)

inside a production repeated list.

Prefer data-driven rendering according to the existing project architecture.

---

# 7. Visual Tokens

Use existing:

* ColorScheme
* ThemeData
* ThemeExtension
* spacing tokens
* typography tokens

Avoid scattering:

Color(...)
TextStyle(...)
BorderRadius(...)

throughout every page.

---

# 8. Performance

For e-commerce pages:

* use lazy lists
* avoid nested scroll views when possible
* specify image dimensions
* avoid unnecessary rebuilds
* use const where appropriate

Follow project performance rules.
