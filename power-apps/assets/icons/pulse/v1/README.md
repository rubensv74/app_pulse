# PULSE Icon Set v1

**Status:** PDS_CANDIDATE  
**Version:** 1.0.1  
**Target:** PULSE Canvas application / Power Apps

This directory is the canonical runtime asset home for the PULSE-owned icon system.

## Counts

- 64 canonical outline pictograms.
- 8 sidebar destinations with dedicated inactive and active assets: 16 files.
- 4 semantic status assets.
- 84 SVG files in total.

## Sidebar set

The sidebar is tailored to the current PULSE shell rather than a generic SaaS menu:

`home`, `overview`, `punch-review`, `punch-list`, `briefing`, `skyline`, `config`, `admin`.

Each destination has:

```text
sidebar/inactive/<name>.svg  → #FFFFFF / 1.8 px
sidebar/active/<name>.svg    → #00C8FF / 2.0 px
```

The geometry is normalized optically for a 20 px host. A common 24×24 viewBox is necessary but not sufficient; each glyph is balanced by occupied area, perceived mass and detail density.

## Canonical rendering

- ViewBox: `0 0 24 24`.
- Base outline: `#0F172A`, 1.8 px.
- Sidebar inactive: `#FFFFFF`, 1.8 px.
- Sidebar active: PULSE BrandAccent `#00C8FF`, 2 px.
- Rounded line caps and joins.
- Transparent background.

The SVG files are repository-local PULSE assets and are not copied from an external icon pack.

Normative documentation lives in `docs/design-system/iconography/`.

Power Apps Studio has already confirmed that imported SVG media renders correctly. The set remains `PDS_CANDIDATE` until the eight sidebar glyphs are visually validated at 20 px in the real dark PULSE sidebar and active/inactive switching is confirmed.
