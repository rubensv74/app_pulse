# PULSE Repository Reorganization Tracker

**Status:** active — architecture/lifecycle decision required  
**Audit baseline:** `1b8c8dffd1185a5f775934b0fceeff3cbe642c55`  
**Audit:** `docs/analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`

This tracker controls structural cleanup independently from runtime feature development.

| Phase | Scope | Status | Runtime risk |
|---:|---|---|---|
| 0 | Entry points, audit, governance | **completed** | none |
| 1A | Archive stale delivery artifacts | **completed** | none |
| 1B | Resolve Design System authority conflict | **completed** | none |
| 1C | Component lifecycle catalog | **completed** | none |
| 2 | Punch Review construction workspace migration | **completed** | low/medium |
| 3 | SQL/database/reference consolidation | **completed** | medium |
| 4 | Guides/sprints/roadmap classification and archive | **completed** | low |
| 5 | Component usage audit + physical legacy cleanup | **blocked by lifecycle decision** | medium |
| 6 | Naming normalization where safe | planned | medium |
| 7 | Link/retrieval QA and closeout | planned | none |

## Completed evidence

### Phase 0

Created:

```text
README.md
docs/README.md
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/analysis/repository/REPOSITORY_AUDIT_2026-08-10.md
```

### Phase 1A

Historical EPIC-01 delivery artifacts were archived under:

```text
docs/archive/deliveries/2026-07-27-epic-01/
```

and removed from repository root / `main/`.

### Phase 1B

`docs/guides/DESIGN_SYSTEM.md` is a superseded compatibility stub. Canonical authority is:

```text
docs/design-system/PULSE_DESIGN_SYSTEM.md
```

### Phase 1C

Created:

```text
docs/design-system/COMPONENT_CATALOG.md
```

### Phase 2

Punch Review construction evidence was moved from:

```text
main/punch-review/
```

to:

```text
docs/development/screens/punch-review/
```

Canonical runtime source remains untouched at:

```text
main/screens/PunchReview/scr_PunchReview.pa.yaml
```

### Phase 3

SQL assets were consolidated to:

```text
sql/export/
sql/import/
sql/schema/warroom/
sql/tools/warroom-schema/
docs/reference/sql/warroom/
```

Competing locations removed:

```text
database/
sql/schema_warroom/
docs/SQL/
```

No SQL file content or runtime contract was changed during the structural move.

### Phase 4

`docs/guides/` was reduced to material that is intentionally still discoverable as guidance/compatibility documentation.

Moved to archive/reference architecture as appropriate:

```text
docs/archive/deliveries/2026-07-27-epic-01/EPIC-01_COMPONENT_INTEGRATION.md
docs/archive/sprints/excel-import-i01/
docs/archive/remediation/2026-08-05/
docs/archive/remediation/home/
docs/archive/superseded-docs/2026-07/ARCHITECTURE.md
docs/archive/roadmaps/ROADMAP_2026-07.md
docs/architecture/integrations/excel-import/EXCEL_IMPORT_ARCHITECTURE.md
```

The old roadmap was archived because its epic status no longer represented current PULSE delivery state.

## Phase 5 evidence

Created:

```text
docs/analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md
```

Confirmed current runtime dependencies:

```text
scr_Home    → cmp_ExecutiveAlertBanner
scr_Home    → cmp_DashboardSectionHeader
scr_Punches → cmp_DetailDrawer_old
```

Therefore none of those three components may be physically removed or moved while their canonical screens depend on them.

No canonical-screen usage was found for:

```text
cmp_ExecutiveKpiCard
cmp_ExecutiveInsightCard
```

They are classified as `ARCHIVE_CANDIDATE`, not deleted.

## Current architecture/lifecycle gate

Before Phase 5 can physically clean the two unreferenced Executive components, the repository needs one policy decision:

```text
OPTION A
main/components = runtime dependencies + active planned/PDS component source only

OPTION B
main/components = runtime dependencies + active planned/PDS source + inactive reusable library
```

Under Option A, unreferenced legacy components should be moved to an archive/legacy source area after a final dependency check.

Under Option B, they may remain in `main/components/`, but inactive components require an explicit lifecycle/catalog marker and must not be selected automatically by agents.

No physical component move should occur before this decision.
