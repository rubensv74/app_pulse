# PULSE Icon System — Power Apps Usage

## Preferred strategy

Use imported SVG Media assets when the navigation color/state is known in advance.

The current PULSE sidebar ships two files per destination, and every physical filename is globally unique:

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

## Confirmed runtime behavior

Confirmed in the real PULSE Canvas app on 2026-08-13:

- SVG files upload through Media;
- active and inactive variants coexist when the physical basenames are unique;
- SVG content renders in Image controls;
- `20×20` + `ImagePosition.Fit` renders without clipping or format failure;
- equal `viewBox` and host dimensions do not guarantee equal optical weight;
- duplicate basenames across active/inactive repository folders are unsuitable for practical batch import;
- white inactive icons and PULSE-cyan active icons switch correctly in the real sidebar;
- the selected row retains background and left-bar cues in addition to icon color.

## Optical QA rule

At 20 px, compare the complete navigation family simultaneously on the real `#07111F` sidebar. Reject/rework any glyph that appears noticeably smaller, thinner, denser, off-center or less recognizable than its neighbors.

The current eight-icon sidebar family passed this canonical test on 2026-08-13.

When changing geometry or introducing a new icon, repeat the comparison and optionally verify 16 px and 24 px fallbacks.

## Recommended component pattern

Keep navigation semantics separate from Power Apps native icon names:

```text
Key      -> navigation state / route identity
IconKey  -> PULSE visual semantic identity
```

Example:

```powerfx
{
    Key: "punchreview",
    Label: "Punch Review",
    IconKey: "punch-review"
}
```

Do not encode native concepts such as `Flag`, `Trending`, `Lock` or `Settings` in `IconKey` when the component is expected to use the PULSE SVG system.

Resolve the Media asset inside the Image control from the semantic `IconKey` and the component's existing active state.

## Accessibility

Do not shrink the click target to the SVG size. Keep the full row/button hit area and treat the 20 px SVG as presentation only.

Interactive hosts should expose meaningful accessible labels and retain a non-color selection cue.
