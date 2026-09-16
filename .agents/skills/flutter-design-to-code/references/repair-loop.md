# Visual Repair Loop

## Purpose

Improve screenshot-to-Flutter implementations through controlled iteration.

---

# Repair Priority

Fix:

1. structure
2. section dimensions
3. padding and margins
4. image sizing
5. typography hierarchy
6. colors
7. border radius
8. shadows
9. micro-details

Do not reverse this order.

---

# One Category at a Time

Example:

Incorrect banner height.

Fix banner geometry.

Run again.

Verify.

Then move to typography.

Avoid changing ten unrelated layout values simultaneously.

---

# Maximum Repair Discipline

After each repair cycle record:

* changed section
* changed property
* reason
* visible result

If repeated changes produce no improvement:

Stop.

Re-evaluate the design analysis.

The original assumption may be incorrect.

---

# Accepted Deviation

Document unavoidable differences.

Example:

Reference:
iOS-specific translucent navigation.

Implementation:
Material 3 navigation bar.

Reason:
Current cross-platform project requirement.

Impact:
Minor visual difference.

Status:
Accepted.
