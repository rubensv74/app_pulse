# Sprint workplan — Home_1 / Punches_1

## Objective

Develop and validate the evolving `Home_1` and `Punches_1` experiences against working baseline 1.0.0.2 while preserving legacy fallback behavior.

## Scope

- `scr_Home_1.pa.yaml`, `scr_Punches_1.pa.yaml`.
- Direct components, flows, SQL procedures and data contracts listed in the two scope inventories.
- Navigation and state contracts between the two screens where an accepted story requires them.
- Focused tests and documentation for modified behavior.

## Out of scope

Deleting legacy screens/components, global solution cleanup, flow consolidation, environment import, connection changes, final release generation, unrelated admin/reporting features and Golden Baseline approval.

## Candidate files and dependencies

Primary candidates live under `power-platform/working-baselines/1.0.0.2/canvas-source/new_pulse_9584c/Src/`. Flow definitions live under the versioned `solution/Workflows/`; relevant SQL, Office Script and documentation paths are enumerated in the scope inventories. Treat `cmp_DetailDrawer_old`, `_Codex` export and unresolved comment bindings as compatibility dependencies.

## Risks

- Cross-navigation currently reaches legacy `Punches`/`Home` screens.
- Comment bindings may fail at runtime despite successful unpack.
- Connection references may require explicit import-time mapping.
- Export has two variants and no approved consolidation decision.
- Direct YAML editing is a preview workflow; changes need Power Apps validation before deployment.

## Implementation sequence

1. Establish focused smoke tests for load, navigation and error states.
2. Validate Home_1 dashboard/project-switch behavior and its direct flows.
3. Validate Home_1 drill-through contract into Punches_1; change navigation only under an accepted story.
4. Validate Punches_1 catalog loading, paging, filters and drawer/comments.
5. Validate `_Codex` export inputs, output contract and failure recovery.
6. Update only directly affected components/flows/SQL and add regression tests.
7. Reconcile documentation, hashes and changed-file manifest before any packaging proposal.

## Validation strategy

Static formula/dependency checks; JSON/XML parsing; focused SQL tests; flow contract inspection; Power Apps Studio smoke testing for both screens; navigation, loading, empty/error, comments and export scenarios. No automatic import is authorized.

## Rollback

The immutable ZIP and versioned official solution are the restoration source. Work only on `workstream/home-1-punches-1`; revert sprint commits or restore individual source files from baseline hashes. Never edit the preserved ZIP.

## Acceptance criteria

- Home_1 and Punches_1 stories pass agreed functional tests.
- Direct dependencies and contracts remain traceable.
- Legacy screens/components remain present.
- No unrelated solution components change.
- Known debt is unchanged or explicitly reduced with evidence.
- Rollback is demonstrated from versioned baseline/commits.
- No import, release or Golden Baseline approval occurs without a separate gate.
