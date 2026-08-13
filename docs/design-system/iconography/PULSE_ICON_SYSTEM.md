# PULSE Icon System

**Status:** PDS_CANDIDATE  
**Version:** 1.0.1  
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

A shared viewBox does **not** guarantee equal perceived size. Every primary navigation glyph must also be normalized by:

1. occupied area inside the 24×24 frame;
2. perceived stroke mass at 20 px;
3. vertical/horizontal visual center;
4. number and size of internal counters;
5. detail density and silhouette recognition.

Avoid icons that are geometrically wide but optically weak at navigation size.

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

`eye` remains available as a generic view/review action but is not the primary Punch Review navigation icon.

## 6. Accessibility

Interactive hosts require meaningful `AccessibleLabel`, adequate hit targets and a non-color selection cue. The visual icon may be 16–24 px while the clickable control should normally be larger.

## 7. Power Apps validation gate

Observed in the real PULSE Canvas app on 2026-08-13:

- `.svg` imports successfully as Media;
- imported SVG renders in an Image control;
- `20×20` with `ImagePosition.Fit` renders without SVG-format failure or clipping.

Still required before `ACTIVE` promotion:

1. compare all eight sidebar concepts at 20 px on the real dark sidebar;
2. verify active/inactive switching;
3. check 16 px and 24 px fallbacks;
4. confirm browser zoom behavior;
5. verify accessible labels on the host controls.

## 8. Source of truth

Runtime SVGs: `power-apps/assets/icons/pulse/v1/`  
Normative docs: `docs/design-system/iconography/`
