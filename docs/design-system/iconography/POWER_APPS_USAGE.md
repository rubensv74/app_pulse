# Using PULSE SVG Icons in Power Apps

## Preferred strategy

Use imported SVG Media assets when the navigation color/state is known in advance. The current PULSE sidebar ships two files per destination:

```text
sidebar/inactive/*.svg  → white
sidebar/active/*.svg    → PULSE cyan
```

Current destinations: `home`, `overview`, `punch-review`, `punch-list`, `briefing`, `skyline`, `config`, `admin`.

## Import pattern

Import both variants with stable Media names, for example:

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

Preferred first validation:

```text
Width = 20
Height = 20
ImagePosition = ImagePosition.Fit
```

## Real PULSE evidence — 2026-08-13

Confirmed in Power Apps Studio:

- SVG files upload through Media;
- SVG content renders in Image controls;
- `20×20` + `ImagePosition.Fit` renders without clipping or format failure.

A side-by-side screenshot of all eight concepts also proved that technical equality is not optical equality. Several glyphs looked materially smaller even though every host was 20×20 and every SVG used `viewBox="0 0 24 24"`.

## Optical QA rule

At 20 px, compare the eight icons simultaneously. The primary silhouette should usually occupy about 17–18 units of the SVG's dominant 24-unit axis, but accept/reject by perception rather than coordinates.

Reject/rework any glyph that appears noticeably smaller, thinner, denser, off-center or less recognizable than its neighbors.

Validate on the actual dark sidebar, not only on a white test canvas. Then verify 16 px and 24 px.

## Accessibility

Use a meaningful `AccessibleLabel` on the interactive host. The hit target should be larger than the visual icon and selection must not rely on cyan alone.
