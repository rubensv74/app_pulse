# PULSE Component Usage Audit — 2026-08-10

**Status:** current evidence  
**Scope:** canonical screens under `power-apps/screens/`  
**Purpose:** prevent unsafe removal/reuse of components based only on filenames or age

## Canonical screens reviewed

```text
power-apps/screens/Home/scr_Home.pa.yaml
power-apps/screens/Punches/scr_Punches_1.pa.yaml
power-apps/screens/PunchReview/scr_PunchReview.pa.yaml
```

## Findings

| Component | Home | Punches | Punch Review | Current action |
|---|---:|---:|---:|---|
| `cmp_ExecutiveAlertBanner` | yes | no | no | `LEGACY_SUPPORTED` — keep until Home_PDS cutover removes dependency |
| `cmp_DashboardSectionHeader` | yes | no | no | `LEGACY_SUPPORTED` — keep until Home_PDS/PDS replacement removes dependency |
| `cmp_DetailDrawer_old` | no | yes | no | `LEGACY_SUPPORTED` — keep until Punches drawer migration is Studio-validated |
| `cmp_ExecutiveKpiCard` | no | no | no | removed from working tree; recoverable via Git history |
| `cmp_ExecutiveInsightCard` | no | no | no | removed from working tree; recoverable via Git history |
| `cmp_SmartFilterBarPro` | no | no | no | removed from active source; no approved current role |

## Evidence

### Home

`cmp_ExecutiveAlertBanner` is instantiated as `cmpHomeExecutiveAlert_1`.

`cmp_DashboardSectionHeader` is instantiated as `cmpHomeKpiSectionHeader_1`.

### Punches

`cmp_DetailDrawer_old` is instantiated as `comp_DetailDrawer_6`.

### Punch Review

None of the three current legacy-supported components is instantiated by Punch Review.

### SmartFilterBar

No `cmp_SmartFilterBarPro` instance was found in the three canonical screens, and it is not part of the approved Home_PDS block plan. Under the active-source policy it was removed rather than preserved as an inactive component-library artifact.

## Lifecycle policy

```text
power-apps/components = current runtime dependencies + approved active/PDS component source
```

Historical-only source is removed from the working tree after dependency audit. Git history provides recovery.

## Naming conclusion

The `_old` suffix on `cmp_DetailDrawer_old` is misleading, but the exact identity remains a live Punches dependency. Its rename/removal is therefore a functional migration, not housekeeping.

## New component rule

If current work needs a reusable component that does not exist:

```text
1. create source in power-apps/components/
2. update docs/design-system/COMPONENT_CATALOG.md
3. add/update PDS component specification when reusable
4. validate in Power Apps Studio
5. consolidate accepted complete source back to power-apps/components/
```
