# PULSE Icon System

**Status:** PDS_CANDIDATE  
**Version:** 1.0.3  
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
preferred validation host: 20×20 px
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

Interactive hosts require meaningful `AccessibleLabel`, adequate hit targets and a non-color selection cue.

## 6. Power Apps validation gate

Observed in the real PULSE Canvas app on 2026-08-13:

- `.svg` imports successfully as Media;
- imported SVG renders in an Image control;
- `20×20` with `ImagePosition.Fit` renders without format failure or clipping;
- side-by-side comparison is required because equal viewBox does not imply equal optical weight;
- active/inactive physical filenames must be unique for reliable import.

Still required before `ACTIVE` promotion:

1. import the uniquely named active/inactive assets;
2. compare all eight concepts at 20 px on the real `#07111F` sidebar;
3. verify active/inactive switching;
4. check 16 px and 24 px fallbacks;
5. confirm browser zoom behavior;
6. verify accessible labels on host controls.

## 7. Source of truth

Runtime SVGs: `power-apps/assets/icons/pulse/v1/`  
Normative docs: `docs/design-system/iconography/`
