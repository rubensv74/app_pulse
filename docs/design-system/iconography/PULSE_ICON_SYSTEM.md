# PULSE Icon System

**Status:** PDS_CANDIDATE  
**Version:** 1.0  
**Date:** 2026-08-13  
**Scope:** PULSE Power Apps iconography

## 1. Purpose

PULSE needs a reliable visual vocabulary that does not depend on the uneven availability or rendering of native Power Apps icons. This specification defines a repository-owned SVG system for sidebar navigation, workspaces, toolbars, data exploration and semantic feedback.

The system is deliberately restrained. Icons support meaning and hierarchy; they are not decorative illustrations.

## 2. Brand alignment

The icon system follows `PULSE_DESIGN_SYSTEM.md`:

| Role | Token | Hex | Icon use |
|---|---|---|---|
| Product identity | BrandAccent | `#00C8FF` | Active dark-navigation icon and deliberate brand accent |
| Navigation surface | BrandDark | `#07111F` | Sidebar background, not the icon stroke |
| Interaction | ActionPrimary | `#1677FF` | Interactive state/focus where appropriate, not PULSE identity |
| Primary icon ink | Text | `#0F172A` | Default outline icon on light surfaces |
| Inverse icon ink | TextWhite | `#FFFFFF` | Inactive icon on dark navigation |
| Success | Success | `#22C55E` | Explicit successful state only |
| Warning | Warning | `#F59E0B` | Explicit warning only |
| Danger | Danger | `#EF4444` | Error/destructive state only |

**Violet is not a PULSE brand color.** It may exist in the broader PDS as a semantic/data color, but it is not used to define the icon system or primary navigation.

## 3. Geometry

Canonical drawing frame:

```text
viewBox: 0 0 24 24
base stroke: 1.8 px
active sidebar stroke: 2.0 px
linecap: round
linejoin: round
background: transparent
```

Design rules:

1. Prefer one dominant silhouette and no more than two supporting details.
2. Preserve a practical optical margin of roughly 2.5–3.5 units.
3. Avoid hairlines, tiny enclosed counters and decorative micro-detail.
4. Prefer rounded geometry consistent with PDS control radii.
5. Optimize first for 20 px, then verify at 16 px and 24 px.
6. Icons representing the same action must retain the same metaphor across screens.
7. A new icon must use the existing grammar rather than introducing a new visual style.

## 4. Families

V1 contains 64 canonical pictograms:

- Navigation: 10.
- Work / Punches: 10.
- Projects: 8.
- Review / Collaboration: 10.
- Data / Actions: 14.
- System / Security: 12.

In addition, the 10 primary sidebar concepts have fixed-color inactive and active variants, and four semantic status assets are supplied.

Total physical SVG files: **88**.

## 5. Sidebar language

PULSE dark navigation uses a two-asset strategy to avoid runtime recoloring dependencies:

```text
inactive → white #FFFFFF / 1.8 px
active   → PULSE cyan #00C8FF / 2.0 px
```

The active state must also have a non-color cue at container level (selected background, accent, label weight, or equivalent). Color alone must not communicate selection.

The initial sidebar concepts are:

```text
home
dashboard
punches
tasks
projects
review
comments
users
analytics
settings
```

## 6. Semantic icon rule

Semantic color is allowed only when the icon itself represents status:

- success → green;
- warning → amber;
- danger/error → red;
- information → ActionPrimary blue.

A generic toolbar icon must remain neutral even if the underlying data can contain warnings or errors.

## 7. Naming

Files use lowercase kebab-case.

Examples:

```text
punch-review.svg
filter-clear.svg
bar-chart.svg
chevron-left.svg
```

Names describe meaning, not shape. Avoid names such as `circle-3`, `icon-blue` or `new-icon`.

## 8. Accessibility

SVG appearance does not replace accessible control semantics.

For every interactive icon in Power Apps:

- provide a meaningful `AccessibleLabel` on the clickable control;
- provide Tooltip where supported and useful;
- maintain an adequate hit target independent from the visual 16–24 px icon size;
- do not use color as the only state signal;
- do not encode two distinct actions with visually indistinguishable icons.

Decorative icons should not create redundant screen-reader announcements.

## 9. Expansion protocol

When a new concept is required:

1. Confirm an existing icon cannot express the concept without ambiguity.
2. Select the correct family.
3. Draw in the 24×24 frame using the canonical stroke grammar.
4. Test visual balance at 16, 20 and 24 px.
5. Add the SVG to the canonical runtime folder.
6. Add it to `manifest.json` and `ICON_CATALOG.md`.
7. If it is a primary dark-sidebar destination, add both inactive and active variants.
8. Validate in Power Apps Studio before considering the icon `ACTIVE`.

## 10. Source of truth

Runtime SVGs:

```text
power-apps/assets/icons/pulse/v1/
```

Normative documentation:

```text
docs/design-system/iconography/
```

V1 is a `PDS_CANDIDATE` until the first real Power Apps import/rendering gate is completed. Repository presence alone is not evidence of runtime compatibility.
