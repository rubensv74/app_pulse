# PULSE Icon Set v1

**Status:** PDS_CANDIDATE  
**Version:** 1.0.3  
**Target:** PULSE Canvas application / Power Apps

This directory is the canonical runtime asset home for the PULSE-owned icon system.

## Counts

- 64 canonical outline pictograms.
- 8 sidebar destinations with dedicated inactive and active assets: 16 files.
- 4 semantic status assets.
- 84 SVG files in total.

## Sidebar set

The sidebar is tailored to the current PULSE shell: `home`, `overview`, `punch-review`, `punch-list`, `briefing`, `skyline`, `config`, `admin`.

Each physical sidebar file has a globally unique basename so both states can be imported into Power Apps Media without collisions:

```text
sidebar/inactive/pulse-nav-<name>-inactive.svg  → #FFFFFF / 1.8 px
sidebar/active/pulse-nav-<name>-active.svg      → #00C8FF / 2.0 px
```

Example:

```text
pulse-nav-home-inactive.svg
pulse-nav-home-active.svg
```

Do not publish active/inactive files with the same basename in different repository folders: Power Apps Media treats uploaded assets as one flat namespace.

The geometry is normalized optically for a 20 px host. A common 24×24 viewBox is necessary but not sufficient; each glyph is balanced by occupied area, perceived mass and detail density.

## Canonical rendering

- ViewBox: `0 0 24 24`.
- Base outline: `#0F172A`, 1.8 px.
- Sidebar inactive: `#FFFFFF`, 1.8 px.
- Sidebar active: PULSE BrandAccent `#00C8FF`, 2 px.
- Rounded line caps and joins.
- Transparent background.

Power Apps Studio has confirmed imported SVG media renders correctly. The set remains `PDS_CANDIDATE` until the sidebar family and active/inactive switching are visually validated in the real PULSE shell.
