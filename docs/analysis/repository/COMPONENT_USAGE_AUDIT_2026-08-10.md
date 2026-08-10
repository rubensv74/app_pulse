# PULSE Component Usage Audit — 2026-08-10

**Status:** completed for canonical-screen scan  
**Scope:** current canonical screens under `main/screens/`  
**Purpose:** prevent removal or reuse of legacy components based only on filenames

## Canonical screens reviewed

```text
main/screens/Home/scr_Home.pa.yaml
main/screens/Punches/scr_Punches_1.pa.yaml
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

This audit answers a narrow question: whether the legacy/review-target components are instantiated by the current canonical screens. It does not prove that an unused component has no historical value or should be deleted.

---

## Findings

| Component | Home | Punches | Punch Review | Runtime conclusion |
|---|---:|---:|---:|---|
| `cmp_ExecutiveAlertBanner` | yes | no | no | **LEGACY_SUPPORTED — runtime dependency** |
| `cmp_DashboardSectionHeader` | yes | no | no | **LEGACY_SUPPORTED — runtime dependency** |
| `cmp_DetailDrawer_old` | no | yes | no | **LEGACY_SUPPORTED — runtime dependency despite `_old` name** |
| `cmp_ExecutiveKpiCard` | no | no | no | no canonical-screen usage found |
| `cmp_ExecutiveInsightCard` | no | no | no | no canonical-screen usage found |

## Evidence

### Home

`cmp_ExecutiveAlertBanner` is instantiated as `cmpHomeExecutiveAlert_1` in the canonical Home screen.

`cmp_DashboardSectionHeader` is instantiated as `cmpHomeKpiSectionHeader_1` in the canonical Home screen.

No canonical Home instance of `cmp_ExecutiveKpiCard`, `cmp_ExecutiveInsightCard` or `cmp_DetailDrawer_old` was found in the screen source scan.

### Punches

`cmp_DetailDrawer_old` is instantiated as `comp_DetailDrawer_6` in the canonical Punches screen.

No canonical Punches instance of the reviewed Executive components was found in the screen source scan.

### Punch Review

No canonical Punch Review instance of the five reviewed legacy components was found in the screen source scan.

---

## Lifecycle corrections required

The `_old` suffix on `cmp_DetailDrawer_old` is misleading because the component is still a live dependency of `scr_Punches`.

Therefore it must not be physically moved, renamed or deleted until Punches is migrated away from it and validated in Studio.

Likewise `cmp_ExecutiveAlertBanner` and `cmp_DashboardSectionHeader` cannot be physically archived while the current Home screen remains the stable production/fallback screen for the parallel Home_PDS rebuild.

`cmp_ExecutiveKpiCard` and `cmp_ExecutiveInsightCard` are candidates for archive/deprecation because no canonical-screen usage was found, but physical removal is a lifecycle decision rather than a mechanical cleanup step. Their definitions should remain in place until that decision is explicitly made.

---

## Safe action from this audit

```text
KEEP in main/components:
- cmp_ExecutiveAlertBanner
- cmp_DashboardSectionHeader
- cmp_DetailDrawer_old

DO NOT SELECT for new PDS work:
- all three above unless a screen-specific compatibility reason requires them

ARCHIVE CANDIDATES — decision required before physical move:
- cmp_ExecutiveKpiCard
- cmp_ExecutiveInsightCard
```

## Architecture/lifecycle gate

Physical cleanup of the two unreferenced Executive components requires one explicit policy decision:

> Should `main/components/` contain only components used by current runtime screens / active planned PDS work, or should it also retain an inactive reusable component library for possible future reuse?

Until that policy is decided, this audit recommends classification only, not deletion or movement.
