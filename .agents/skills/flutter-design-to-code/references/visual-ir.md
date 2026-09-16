# Visual IR

Visual IR is a structured representation of a visual source.

It describes the design.

It does not describe Flutter implementation details.

---

# Goals

Visual IR should make the following questions answerable:

* What sections exist?
* What is their order?
* Which sections scroll?
* Which elements are fixed?
* What visual hierarchy exists?
* Which elements repeat?
* Which elements overlap?
* Which measurements are approximate?
* Which elements are interactive?

---

# Section Model

Each section should include:

* id
* type
* visual role
* approximate dimensions
* background
* padding
* layout
* children
* interaction hints
* confidence

---

# Example

{
"pageId": "home",
"viewport": {
"width": 375,
"height": 812
},
"scroll": {
"direction": "vertical"
},
"sections": [
{
"id": "header",
"type": "app_header",
"height": 88,
"layout": "horizontal",
"confidence": "high"
},
{
"id": "banner",
"type": "carousel",
"padding": {
"left": 16,
"right": 16,
"top": 12,
"bottom": 12
},
"layout": "horizontal",
"confidence": "high"
}
]
}

---

# Rules

Visual IR must not:

* contain hundreds of absolute pixel coordinates
* contain generated Dart code
* assume backend data models
* invent interaction behavior

Visual IR may contain:

* approximate measurements
* confidence levels
* interaction hints
* visual hierarchy
* section boundaries
