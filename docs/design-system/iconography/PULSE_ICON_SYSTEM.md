# PULSE Icon System

**Status:** ACTIVE  
**Version:** 1.0.4  
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

```text
viewBox: 0 0 24 24
base stroke: 1.8 px
active sidebar stroke: 2.0 px
linecap: round
linejoin: round
background: transparent
canonical sidebar host: 20×20 px
```

A shared viewBox does not guarantee equal perceived size. Primary navigation glyphs are normalized by occupied area, perceived stroke mass, visual center, internal detail density and silhouette recognition. Optical balance overrides mathematical equality.

## 4. Sidebar family

Current destinations: `home`, `overview`, `punch-review`, `punch-list`, `briefing`, `skyline`, `config`, `admin`.

Each has white inactive and cyan active variants. Physical filenames follow:

```text
pulse-nav-<destination>-inactive.svg
pulse-nav-<destination>-active.svg
```

This naming rule is part of the runtime contract. Power Apps Media uses a flat namespace, so state variants must never rely on repository folders alone to distinguish identical basenames.

## 5. Accessibility

Interactive hosts require meaningful `AccessibleLabel`, adequate hit targets and a non-color selection cue. The sidebar keeps the full gallery row as the click target while the SVG itself remains visually compact.

## 6. Power Apps validation

Validated in the real PULSE Canvas app on 2026-08-13:

- `.svg` imports successfully as Media;
- active and inactive assets with unique basenames can coexist in Media;
- imported SVG renders correctly in Image controls;
- `20×20` with `ImagePosition.Fit` renders without clipping or format failure;
- all eight sidebar concepts were reviewed together on the real `#07111F` sidebar;
- inactive icons render in white and the active icon switches to PULSE cyan `#00C8FF`;
- the selected row retains an additional non-color cue through its active background and left accent bar;
- no material optical imbalance remains at the canonical 20 px navigation size;
- the runtime test confirmed the final naming rule and active/inactive state model.

The canonical sidebar gate is therefore **PASS** and the system is promoted to `ACTIVE`.

### Recommended regression checks

These are not blockers for v1.0.4 but should be repeated when the sidebar geometry or icon host changes:

1. 16 px fallback check;
2. 24 px fallback check;
3. browser zoom / display scaling check;
4. accessibility review of host controls;
5. optical comparison after adding any new navigation concept.

## 7. Source of truth

Runtime SVGs: `power-apps/assets/icons/pulse/v1/`  
Normative docs: `docs/design-system/iconography/`
