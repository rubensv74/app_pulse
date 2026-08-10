# PULSE Repository Reorganization Tracker

**Status:** active — Phase 5 policy resolved  
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
| 5 | Component usage audit + physical legacy cleanup | **completed** | medium |
| 6 | Naming normalization where safe | **in progress** | medium |
| 7 | Link/retrieval QA and closeout | planned | none |

## Repository lifecycle decision

On 2026-08-10 the repository adopted **Option A**:

```text
main/components = runtime dependencies + active planned/PDS component source only
```

Additional rule:

> When current work needs a new reusable component, its canonical source is created under `main/components/` in the same development cycle. The component catalog is updated immediately, and reusable PDS components also receive a specification under `docs/design-system/components/`.

Historical component source does not remain in the active component pool merely for possible future reuse.

## Phase 5 applied

Usage audit:

```text
docs/analysis/repository/COMPONENT_USAGE_AUDIT_2026-08-10.md
```

Confirmed live dependencies kept in `main/components/`:

```text
scr_Home    → cmp_ExecutiveAlertBanner
scr_Home    → cmp_DashboardSectionHeader
scr_Punches → cmp_DetailDrawer_old
```

No canonical-screen usage was found for:

```text
cmp_ExecutiveKpiCard
cmp_ExecutiveInsightCard
```

Under Option A they were moved from the active component pool to:

```text
docs/archive/components/
```

Their source is retained for traceability, but they are not normal reuse candidates.

## Current controlled phase — Phase 6

Normalize names only where doing so cannot break Power Apps/runtime contracts or active references.

Rules:

- do not rename `cmp_DetailDrawer_old` while `scr_Punches` still depends on that exact Canvas component identity;
- do not rename canonical Power Apps screen/component identities merely to improve repository aesthetics;
- safe documentation/path normalization may proceed;
- if a name is misleading but live, document lifecycle status rather than performing a cosmetic runtime rename.

Phase 6 should prefer **no rename** over a rename with uncertain runtime impact.
