# PULSE Icon Set Changelog

## 1.0.3 — 2026-08-13

### Changed

- Renamed all 16 sidebar SVG files to globally unique Power Apps-safe basenames.
- Canonical pattern is now `pulse-nav-<destination>-<state>.svg`.
- Active and inactive assets can now be imported together without filename collisions.

### Learned

- Repository folders do not protect Media-name uniqueness in Power Apps; imported media assets share a flat namespace.
- Runtime asset naming must therefore encode both semantic destination and state in the physical filename.

## 1.0.2 — 2026-08-13

### Changed

- Rebalanced seven of the eight sidebar glyphs after side-by-side 20 px Power Apps Studio evidence.
- Enlarged the occupied optical envelope for Home, Overview, Punch Review, Punch List, Briefing, Skyline and Admin.
- Simplified internal detail where it weakened recognition at navigation size.
- Kept Config as the optical benchmark because its weight already read clearly at 20 px.

### Learned

- A common `24×24` viewBox and identical Image control size do not guarantee equal perceived icon size.
- Sidebar acceptance is based on optical weight, silhouette recognition and visual center at 20 px, not mathematical bounds alone.

## 1.0.1 — 2026-08-13

### Changed

- Replaced the generic sidebar set with the exact current PULSE navigation.
- Reworked Punch Review from an eye metaphor to a target + check concept.

## 1.0.0 — 2026-08-13

### Added

- Initial 64-icon PULSE outline library.
- Dedicated dark-sidebar inactive and active variants.
- Semantic success, warning, danger and information assets aligned with PDS colors.
- Manifest and normative usage documentation.
