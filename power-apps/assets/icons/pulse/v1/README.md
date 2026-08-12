# PULSE Icon Set v1

**Status:** PDS_CANDIDATE  
**Version:** 1.0.0  
**Target:** PULSE Canvas application / Power Apps

This directory is the canonical runtime asset home for the first PULSE-owned icon system.

## Structure

```text
v1/
├── outline/
│   ├── navigation/
│   ├── work/
│   ├── project/
│   ├── review/
│   ├── data/
│   └── system/
├── sidebar/
│   ├── inactive/
│   └── active/
├── semantic/
├── manifest.json
└── README.md
```

## Counts

- 64 canonical outline pictograms.
- 10 sidebar pictograms with dedicated inactive and active assets: 20 files.
- 4 semantic status assets.
- 88 SVG files in total.

## Canonical rendering

- ViewBox: `0 0 24 24`.
- Base outline: `#0F172A`, 1.8 px.
- Sidebar inactive: `#FFFFFF`, 1.8 px.
- Sidebar active: PULSE BrandAccent `#00C8FF`, 2 px.
- Rounded line caps and joins.
- Transparent background.

The SVG files are repository-local PULSE assets and are not copied from an external icon pack.

Normative documentation:

```text
docs/design-system/iconography/PULSE_ICON_SYSTEM.md
docs/design-system/iconography/ICON_CATALOG.md
docs/design-system/iconography/POWER_APPS_USAGE.md
```

Do not treat Git presence as proof of Studio validation. Visual/import validation in the target Power Apps application remains required before promoting the set from `PDS_CANDIDATE` to `ACTIVE`.
