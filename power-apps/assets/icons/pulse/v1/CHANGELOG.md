# PULSE Icon Set Changelog

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
