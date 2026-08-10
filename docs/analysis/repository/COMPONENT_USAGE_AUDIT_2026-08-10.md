# PULSE Component Usage Audit — 2026-08-10

**Status:** completed  
**Scope:** current canonical screens under `main/screens/`  
**Purpose:** prevent removal or reuse of legacy components based only on filenames

## Canonical screens reviewed

```text
main/screens/Home/scr_Home.pa.yaml
main/screens/Punches/scr_Punches_1.pa.yaml
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

This audit answers whether the legacy/review-target components are instantiated by the current canonical screens. It does not prove that an unused component has no historical value.

---

## Findings

| Component | Home | Punches | Punch Review | Runtime conclusion |
|---|---:|---:|---:|---|
| `cmp_ExecutiveAlertBanner` | yes | no | no | **LEGACY_SUPPORTED — runtime dependency** |
| `cmp_DashboardSectionHeader` | yes | no | no | **LEGACY_SUPPORTED — runtime dependency** |
| `cmp_DetailDrawer_old` | no | yes | no | **LEGACY_SUPPORTED — runtime dependency despite `_old` name** |
| `cmp_ExecutiveKpiCard` | no | no | no | **ARCHIVED** after Option A lifecycle decision |
| `cmp_ExecutiveInsightCard` | no | no | no | **ARCHIVED** after Option A lifecycle decision |

## Evidence

### Home

`cmp_ExecutiveAlertBanner` is instantiated as `cmpHomeExecutiveAlert_1` in the canonical Home screen.

`cmp_DashboardSectionHeader` is instantiated as `cmpHomeKpiSectionHeader_1` in the canonical Home screen.

No canonical Home instance of `cmp_ExecutiveKpiCard`, `cmp_ExecutiveInsightCard` or `cmp_DetailDrawer_old` was found in the screen source scan.

### Punches

`cmp_DetailDrawer_old` is instantiated as `comp_DetailDrawer_6` in the canonical Punches screen.

### Punch Review

No canonical Punch Review instance of the five reviewed legacy components was found in the screen source scan.

---

## Lifecycle decision applied

PULSE adopted repository component lifecycle **Option A**:

```text
main/components = runtime dependencies + active planned/PDS component source only
```

Therefore:

```text
KEPT in main/components because currently required:
- cmp_ExecutiveAlertBanner
- cmp_DashboardSectionHeader
- cmp_DetailDrawer_old

MOVED to docs/archive/components because no canonical-screen usage was found:
- cmp_ExecutiveKpiCard
- cmp_ExecutiveInsightCard
```

The archived files are retained for traceability and are not normal reuse candidates.

## Important naming conclusion

The `_old` suffix on `cmp_DetailDrawer_old` is misleading, but it cannot be renamed safely as a cosmetic cleanup because `scr_Punches` currently instantiates that exact Canvas component identity.

The safe policy is to preserve the live name until Punches is migrated to a replacement component and Studio validation succeeds.

## New component rule

If future work needs a reusable component that does not yet exist, create its canonical source immediately under:

```text
main/components/
```

and update `docs/design-system/COMPONENT_CATALOG.md` in the same development cycle. A reusable PDS component should also receive a specification under `docs/design-system/components/`.
