# PULSE Repository Reorganization Tracker

**Status:** completed  
**Audit baseline:** `1b8c8dffd1185a5f775934b0fceeff3cbe642c55`  
**Audit:** `docs/analysis/repository/REPOSITORY_AUDIT_2026-08-10.md`  
**Closeout:** `docs/analysis/repository/REPOSITORY_REORGANIZATION_CLOSEOUT_2026-08-10.md`

This tracker controlled structural cleanup independently from runtime feature development.

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
| 6 | Naming normalization where safe | **completed** | medium |
| 7 | Link/retrieval QA and closeout | **completed** | none |

## Repository lifecycle decision

On 2026-08-10 the repository adopted **Option A**:

```text
main/components = runtime dependencies + active planned/PDS component source only
```

Additional permanent rule:

> When current work needs a new reusable component, its canonical source is created under `main/components/` in the same development cycle. The component catalog is updated immediately, and reusable PDS components also receive a specification under `docs/design-system/components/`.

Historical component source does not remain in the active component pool merely for possible future reuse.

## Phase 5 result

Confirmed live dependencies kept in `main/components/`:

```text
scr_Home    → cmp_ExecutiveAlertBanner
scr_Home    → cmp_DashboardSectionHeader
scr_Punches → cmp_DetailDrawer_old
```

Inactive components moved to history:

```text
docs/archive/components/cmp_ExecutiveKpiCard.pa.yaml
docs/archive/components/cmp_ExecutiveInsightCard.pa.yaml
```

The newly required `cmp_PageHeaderPro` was published to the active component source set at:

```text
main/components/cmp_PageHeaderPro.pa.yaml
```

## Phase 6 result

No unsafe cosmetic runtime rename was performed.

Live naming exceptions are documented at:

```text
docs/governance/NAMING_EXCEPTIONS.md
```

In particular:

```text
scr_Punches_1.pa.yaml
cmp_DetailDrawer_old.pa.yaml
```

remain unchanged until explicit runtime migrations make renaming safe.

## Phase 7 result

Post-migration stale-path searches returned no repository-code matches for:

```text
main/punch-review
sql/schema_warroom
database/warroom/tools
docs/SQL
docs/guides/EXCEL_IMPORT_ARCHITECTURE.md
docs/guides/ROADMAP.md
main/components/cmp_ExecutiveKpiCard.pa.yaml
main/components/cmp_ExecutiveInsightCard.pa.yaml
```

Canonical root, `main/`, `sql/`, Punch Review workspace and archive component locations were also directly verified through repository contents.

## Final state

Repository reorganization is closed for the current scope.

Future organization changes are governed by:

```text
docs/governance/REPOSITORY_STRUCTURE_STANDARD.md
docs/governance/NAMING_EXCEPTIONS.md
docs/design-system/COMPONENT_CATALOG.md
```

Structural cleanup must continue as normal governance during feature work rather than through parallel ad-hoc folder creation.
