# Visual Repair Strategy

## Principle

Fix the smallest responsible layer.

Do not rewrite an entire page to fix a single card.

---

# Repair Hierarchy

Preferred order:

1. theme token
2. shared component
3. section component
4. page layout
5. local widget adjustment

Example:

All product prices are too small.

Check:

Price typography token.

Do not update every ProductCard individually.

---

# Geometry Repair

When dimensions differ:

Prefer:

* AspectRatio
* LayoutBuilder
* Expanded
* Flexible
* spacing tokens

Avoid:

* arbitrary device-specific values

---

# Typography Repair

Check:

1. font family
2. font size
3. font weight
4. line height
5. maxLines
6. overflow
7. baseline alignment

Do not only change fontSize.

---

# Image Repair

Check:

* BoxFit
* aspect ratio
* crop
* alignment
* container constraints

A correct image with incorrect BoxFit can look completely different.

---

# Repair Scope

Each iteration should preferably repair:

One major issue

or

One shared root cause.

Avoid uncontrolled large changes.

---

# When To Stop

Stop repairing when:

* parity target is achieved
* remaining differences are accepted
* further repair requires unsupported assumptions
* platform differences are unavoidable
* source reference is ambiguous
