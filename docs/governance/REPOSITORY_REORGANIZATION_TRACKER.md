# PULSE Repository Reorganization Tracker

**Status:** active  
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
| 4 | Guides/sprints/roadmap classification and archive | **in progress** | low |
| 5 | Component usage audit + physical legacy cleanup | planned | medium |
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

No component source was moved or deleted in this phase.

### Phase 2

Punch Review construction evidence was moved atomically from:

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

The workspace README was updated to use the new paths.

### Phase 3

SQL assets were consolidated to the canonical model:

```text
sql/export/
sql/import/
sql/schema/warroom/
sql/tools/warroom-schema/
docs/reference/sql/warroom/
```

Removed competing locations:

```text
database/
sql/schema_warroom/
docs/SQL/
```

No SQL file content or runtime contract was changed during the structural move.

## Current controlled phase — Phase 4

Classify `docs/guides/` by lifecycle and purpose.

Rules:

- genuine reusable step-by-step guidance may remain in `docs/guides/`;
- historical sprint records move to `docs/archive/sprints/`;
- superseded implementation/remediation evidence moves to archive;
- architecture documents move to `docs/architecture/` only when they represent current architecture;
- roadmap/product-planning material must receive one unambiguous canonical location before the old guide copy is removed.

Phase 4 must not modify Power Apps runtime code.
