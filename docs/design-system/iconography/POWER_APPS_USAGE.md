# Using PULSE SVG Icons in Power Apps

## Preferred strategy

Use imported SVG Media assets when the navigation color/state is known in advance.

The current PULSE sidebar ships two files per destination, but **every physical filename is globally unique**:

```text
sidebar/inactive/pulse-nav-<destination>-inactive.svg
sidebar/active/pulse-nav-<destination>-active.svg
```

Current destinations: `home`, `overview`, `punch-review`, `punch-list`, `briefing`, `skyline`, `config`, `admin`.

## Power Apps Media naming rule

Power Apps Media behaves as a flat asset namespace. Two files named `home.svg` cannot be safely treated as distinct merely because they came from different repository folders.

Therefore the repository filename itself must encode state:

```text
pulse-nav-home-inactive.svg
pulse-nav-home-active.svg
pulse-nav-punch-review-inactive.svg
pulse-nav-punch-review-active.svg
```

This is the canonical rule for all future PULSE media assets that have state variants.

## Import pattern

After import, Power Apps may normalize hyphens in the Media identifier. Use the actual identifier shown by Studio. Conceptually:

```powerfx
If(
    ThisItem.IsActive,
    pulse_nav_punch_review_active,
    pulse_nav_punch_review_inactive
)
```

Preferred visual host:

```text
Width = 20
Height = 20
ImagePosition = ImagePosition.Fit
```

## Real PULSE evidence — 2026-08-13

Confirmed in Power Apps Studio:

- SVG files upload through Media;
- SVG content renders in Image controls;
- `20×20` + `ImagePosition.Fit` renders without clipping or format failure;
- equal `viewBox` and host dimensions do not guarantee equal optical weight;
- duplicate basenames across active/inactive repository folders are unsuitable for practical batch import.

## Optical QA rule

At 20 px, compare the eight icons simultaneously on the real `#07111F` sidebar. Reject/rework any glyph that appears noticeably smaller, thinner, denser, off-center or less recognizable than its neighbors. Then verify 16 px and 24 px.

## Accessibility

Use a meaningful `AccessibleLabel` on the interactive host. The hit target should be larger than the visual icon and selection must not rely on cyan alone.
