# PULSE Icon System

**Status:** PDS_CANDIDATE  
**Version:** 1.0.2  
**Date:** 2026-08-13  
**Scope:** PULSE Power Apps iconography

## 1. Purpose

PULSE uses a repository-owned SVG vocabulary so navigation and premium components do not depend on uneven native Power Apps icon availability or rendering.

## 2. Brand alignment

| Role | Hex | Icon use |
|---|---|---|
| PULSE BrandAccent | `#00C8FF` | Active dark-navigation icon / deliberate brand accent |
| BrandDark | `#07111F` | Sidebar surface |
| ActionPrimary | `#1677FF` | Interaction/focus, not brand identity |
| Primary ink | `#0F172A` | Default outline icon on light surfaces |
| Inverse ink | `#FFFFFF` | Inactive dark-navigation icon |
| Success | `#22C55E` | Actual success state only |
| Warning | `#F59E0B` | Actual warning state only |
| Danger | `#EF4444` | Error/destructive state only |

Violet is not a PULSE brand/iconography color.

## 3. Geometry and optical normalization

Canonical frame:

```text
viewBox: 0 0 24 24
base stroke: 1.8 px
active sidebar stroke: 2.0 px
linecap: round
linejoin: round
background: transparent
preferred validation host: 20×20 px
```

A shared viewBox does **not** guarantee equal perceived size. Primary navigation glyphs must be normalized optically by occupied area, perceived stroke mass, visual center, internal-counter size, detail density and silhouette recognition.

For the current sidebar, the primary silhouette should normally occupy roughly 17–18 units on its dominant axis inside the 24×24 frame. This is a starting envelope, not a rigid mathematical rule: optical balance overrides equal coordinates.

Avoid icons that are geometrically wide but visually weak, or icons whose internal detail collapses at 20 px.

## 4. Families

V1 contains 64 canonical outline pictograms plus dedicated sidebar and semantic assets.

The current sidebar set is intentionally specific to the real PULSE shell:

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

Each exists in white inactive and cyan active variants.

## 5. Sidebar metaphors

| Destination | Metaphor |
|---|---|
| Home | house |
| Overview | operational bars + trend |
| Punch Review | punch target + review check |
| Punch List | structured work-item list |
| Briefing | executive message bubble |
| Skyline | operational skyline/profile |
| Config | gear |
| Admin | protected user / shield |

`eye` remains available as a generic view action but is not the Punch Review navigation metaphor.

## 6. Accessibility

Interactive hosts require meaningful `AccessibleLabel`, adequate hit targets and a non-color selection cue. The visual icon may be 16–24 px while the clickable control should normally be larger.

## 7. Power Apps validation gate

Observed in the real PULSE Canvas app on 2026-08-13:

- `.svg` imports successfully as Media;
- imported SVG renders in an Image control;
- `20×20` with `ImagePosition.Fit` renders without SVG-format failure or clipping;
- side-by-side 20 px comparison is required because equal viewBox does not imply equal optical weight.

Still required before `ACTIVE` promotion:

1. import/reload v1.0.2 sidebar assets;
2. compare all eight concepts at 20 px on the real `#07111F` sidebar;
3. verify active/inactive switching;
4. check 16 px and 24 px fallbacks;
5. confirm browser zoom behavior;
6. verify accessible labels on host controls.

## 8. Source of truth

Runtime SVGs: `power-apps/assets/icons/pulse/v1/`  
Normative docs: `docs/design-system/iconography/`
