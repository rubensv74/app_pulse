# PULSE Icon Set Changelog

## 1.0.2 — 2026-08-13

### Changed

- Rebalanced seven of the eight sidebar glyphs after side-by-side 20 px Power Apps Studio evidence.
- Enlarged the occupied optical envelope for Home, Overview, Punch Review, Punch List, Briefing, Skyline and Admin.
- Simplified internal detail where it weakened recognition at navigation size.
- Kept Config as the optical benchmark because its weight already read clearly at 20 px.

### Learned

- A common `24×24` viewBox and identical Image control size do not guarantee equal perceived icon size.
- Sidebar acceptance is based on optical weight, silhouette recognition and visual center at 20 px, not mathematical bounds alone.

### Validation

- SVG import and rendering remain confirmed in the real PULSE Canvas app.
- A second side-by-side screenshot at 20 px exposed the optical imbalance that triggered this revision.
- Final validation must now be repeated with v1.0.2 on the actual dark sidebar.

## 1.0.1 — 2026-08-13

### Changed

- Replaced the generic 10-destination sidebar set with the exact current PULSE navigation: Home, Overview, Punch Review, Punch List, Briefing, Skyline, Config and Admin.
- Reworked Punch Review from an eye metaphor to a target + check concept.
- Added optical normalization as an explicit requirement; equal viewBox no longer implies equal perceived size.
- Kept fixed white inactive and PULSE-cyan active SVG variants to avoid runtime recoloring dependency.

### Validation

- Real Power Apps Studio import/rendering of SVG media confirmed.
- A 20×20 Image control with `ImagePosition.Fit` rendered the SVG without clipping or format failure.
- Final visual balance of all eight sidebar icons on the dark sidebar remains pending.

## 1.0.0 — 2026-08-13

### Added

- Initial 64-icon PULSE outline library.
- Dedicated dark-sidebar inactive and active variants.
- Semantic success, warning, danger and information assets aligned with PDS colors.
- Manifest and normative usage documentation.
