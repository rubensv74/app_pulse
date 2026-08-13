# PULSE Icon Catalog

**Status:** ACTIVE  
**Version:** 1.0.4  
**Canonical runtime root:** `power-apps/assets/icons/pulse/v1/`

The library contains 64 canonical outline pictograms plus dedicated sidebar and semantic variants.

## Canonical outline families

The canonical outline families remain: Navigation (10), Work/Punches (10), Projects (10), Review/Collaboration (10), Data/Actions (12) and System/Security (12).

## Sidebar variants

Each destination has two Power Apps-safe filenames:

| Destination | Inactive file | Active file | Visual metaphor |
|---|---|---|---|
| Home | `pulse-nav-home-inactive.svg` | `pulse-nav-home-active.svg` | house |
| Overview | `pulse-nav-overview-inactive.svg` | `pulse-nav-overview-active.svg` | bars + operational trend |
| Punch Review | `pulse-nav-punch-review-inactive.svg` | `pulse-nav-punch-review-active.svg` | target + check |
| Punch List | `pulse-nav-punch-list-inactive.svg` | `pulse-nav-punch-list-active.svg` | structured list |
| Briefing | `pulse-nav-briefing-inactive.svg` | `pulse-nav-briefing-active.svg` | message / concise briefing |
| Skyline | `pulse-nav-skyline-inactive.svg` | `pulse-nav-skyline-active.svg` | skyline/profile bars |
| Config | `pulse-nav-config-inactive.svg` | `pulse-nav-config-active.svg` | gear |
| Admin | `pulse-nav-admin-inactive.svg` | `pulse-nav-admin-active.svg` | shield + user |

The filename pattern is normative: `pulse-nav-<destination>-<state>.svg`. State must be encoded in the basename because Power Apps Media uses a flat namespace.

The eight concepts and both active/inactive states were validated in the real PULSE sidebar at the canonical 20 px host size on 2026-08-13.

## Semantic variants

The system includes dedicated semantic assets for:

- success;
- warning;
- danger;
- information.

Semantic color is reserved for genuine semantic state and must not be used as decorative navigation color.

## Counts

```text
64 canonical outline pictograms
16 sidebar SVGs (8 destinations × 2 states)
4 semantic SVGs
84 physical SVG files
```
