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
| 2 | Punch Review construction workspace migration | planned | low/medium |
| 3 | SQL/database/reference consolidation | planned | medium |
| 4 | Guides/sprints/roadmap classification and archive | planned | low |
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

`docs/guides/DESIGN_SYSTEM.md` is now a superseded compatibility stub. Canonical authority is:

```text
docs/design-system/PULSE_DESIGN_SYSTEM.md
```

### Phase 1C

Created:

```text
docs/design-system/COMPONENT_CATALOG.md
```

No component source was moved or deleted in this phase.

## Next controlled phase

Phase 2 should migrate Punch Review construction evidence out of `main/punch-review/` and into:

```text
docs/development/screens/punch-review/
```

Before deleting the old location, update all repository links and classify each historical block as pasteable, instructional, optional seed or archived.

Do not mix this migration with changes to `main/screens/PunchReview/scr_PunchReview.pa.yaml`.
