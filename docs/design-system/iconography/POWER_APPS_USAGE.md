# Using PULSE SVG Icons in Power Apps

## Preferred strategy

Use imported SVG Media assets when the navigation color/state is known in advance. This avoids dependency on native Power Apps icon availability and avoids runtime recoloring complexity.

The current PULSE sidebar ships two files per destination:

```text
sidebar/inactive/*.svg  → white
sidebar/active/*.svg    → PULSE cyan
```

## Current sidebar files

```text
home
overview
punch-review
punch-list
briefing
skyline
config
admin
```

## Import pattern

Import both variants and give them stable Media names, for example:

```text
pulse_punch_review_inactive
pulse_punch_review_active
```

Bind the host Image conceptually as:

```powerfx
If(
    ThisItem.IsActive,
    pulse_punch_review_active,
    pulse_punch_review_inactive
)
```

Recommended first validation:

```text
Width = 20
Height = 20
ImagePosition = ImagePosition.Fit
```

The selected container must still provide a non-color cue such as selected background, accent bar or label weight.

## Real PULSE validation evidence — 2026-08-13

Confirmed in Power Apps Studio:

- SVG files upload successfully through Media;
- SVG content renders in Image controls;
- a `20×20` Image using `ImagePosition.Fit` renders without clipping or format failure.

This proves format/runtime compatibility for the tested files. It does **not** yet prove that all glyphs have equal optical weight.

## Optical QA

At 20 px compare the eight sidebar icons side-by-side on `BrandDark #07111F`. Reject/rework any glyph that appears noticeably smaller, thinner, denser or less recognizable than its neighbors even if its viewBox is identical.

Then verify 16 px and 24 px.

## Accessibility

Use a meaningful `AccessibleLabel` on the interactive host. The hit target should be larger than the visual icon and selection must not rely on cyan alone.
